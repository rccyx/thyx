#!/usr/bin/env bash

THYX_MISSING_DEPS=()
THYX_RUNTIME_MANIFEST=""

_thyx_read_clean() {
  local file="${1:?}"
  [ -f "${file}" ] || return 1
  sed -e 's/^[[:space:]]*#.*//' -e '/^[[:space:]]*$/d' "${file}"
}

_thyx_find_one_command() {
  local cmd
  for cmd in "$@"; do
    if command -v "${cmd}" >/dev/null 2>&1; then
      printf '%s\n' "${cmd}"
      return 0
    fi
  done
  return 1
}

_thyx_check_install_deps() {
  local script_dir="${1:?}"
  THYX_MISSING_DEPS=()

  _thyx_step "deps"
  _thyx_require_commands_file "${script_dir}/data/install.commands"
  _thyx_require_runtime_packages "${script_dir}"
  _thyx_require_one_command "sddm greeter" sddm-greeter-qt6 sddm-greeter

  [ "${EUID:-$(id -u)}" -ne 0 ] && _thyx_require_command sudo
  _thyx_source_has_fonts && _thyx_require_command fc-cache

  _thyx_report_missing_deps "${script_dir}"
  _thyx_ok "deps ok"
}

_thyx_check_uninstall_deps() {
  local script_dir="${1:?}"
  THYX_MISSING_DEPS=()

  _thyx_step "deps"
  _thyx_require_commands_file "${script_dir}/data/uninstall.commands"

  [ "${EUID:-$(id -u)}" -ne 0 ] && _thyx_require_command sudo
  [ -d "${THYX_FONTS_DST}" ] && _thyx_require_command fc-cache

  _thyx_report_missing_deps
  _thyx_ok "deps ok"
}

_thyx_install_runtime_deps() {
  local script_dir="${1:?}"
  local manifest manager
  local missing=()

  _thyx_step "packages"

  manifest="$(_thyx_prepare_runtime_manifest "${script_dir}")"
  _thyx_info "manifest: ${manifest}"

  manager="$(_thyx_package_manager)" || _thyx_die "no supported package manager found"
  _thyx_gentoo_portage_tree_required "${manager}"
  _thyx_install_gentoo_use "${script_dir}" "${manager}"
  _thyx_missing_packages "${manifest}" missing

  if [ "${#missing[@]}" -eq 0 ]; then
    _thyx_ok "runtime packages already installed"
    return 0
  fi

  _thyx_run_package_install "${manager}" "${missing[@]}"
  missing=()
  _thyx_missing_packages "${manifest}" missing

  if [ "${#missing[@]}" -gt 0 ]; then
    printf '\n%s\n\n' "runtime packages still missing after install"
    printf '  - %s\n' "${missing[@]}"
    printf '\n'
    _thyx_die "runtime package install did not satisfy the selected manifest"
  fi

  _thyx_ok "runtime packages installed"
}

_thyx_install_gentoo_use() {
  local script_dir="${1:?}"
  local manager="${2:?}"
  local use_file="${script_dir}/data/deps.gentoo.use"

  [ "${manager}" = "emerge" ] || return 0
  [ -f "${use_file}" ] || _thyx_die "dependency manifest missing: ${use_file}"

  _thyx_run mkdir -p /etc/portage/package.use
  _thyx_run install -m 0644 -- "${use_file}" /etc/portage/package.use/thyx
}

_thyx_prepare_runtime_manifest() {
  local script_dir="${1:?}" manifest

  if [ -n "${THYX_RUNTIME_MANIFEST}" ]; then
    printf '%s\n' "${THYX_RUNTIME_MANIFEST}"
    return 0
  fi

  manifest="$(_thyx_runtime_manifest "${script_dir}")"
  [ -f "${manifest}" ] || _thyx_die "dependency manifest missing: ${manifest}"

  if [ "$(basename "${manifest}")" = "deps.generic" ]; then
    _thyx_print_unsupported_distro "${script_dir}"
    _thyx_die "unsupported distro: install the generic dependencies manually"
  fi

  THYX_RUNTIME_MANIFEST="${manifest}"
  printf '%s\n' "${THYX_RUNTIME_MANIFEST}"
}

_thyx_require_command() {
  local cmd="${1:?}"
  command -v "${cmd}" >/dev/null 2>&1 || THYX_MISSING_DEPS+=("command: ${cmd}")
}

_thyx_require_one_command() {
  local label="${1:?}"
  shift
  _thyx_find_one_command "$@" >/dev/null || THYX_MISSING_DEPS+=("${label}: $*")
}

_thyx_require_commands_file() {
  local file="${1:?}" cmd
  [ -f "${file}" ] || _thyx_die "dependency manifest missing: ${file}"

  while IFS= read -r cmd; do
    _thyx_require_command "${cmd}"
  done < <(_thyx_read_clean "${file}")
}

_thyx_require_package_manifest() {
  local file="${1:?}" package
  [ -f "${file}" ] || _thyx_die "dependency manifest missing: ${file}"

  _thyx_gentoo_portage_tree_required "$(_thyx_package_manager || true)"

  while IFS= read -r package; do
    _thyx_package_installed "${package}" || THYX_MISSING_DEPS+=("package: ${package}")
  done < <(_thyx_read_clean "${file}")
}

_thyx_require_runtime_packages() {
  local script_dir="${1:?}" manifest
  manifest="$(_thyx_prepare_runtime_manifest "${script_dir}")"
  _thyx_require_package_manifest "${manifest}"
}

_thyx_runtime_manifest() {
  local script_dir="${1:?}" manifest manager

  manifest="$(_thyx_manifest_from_map "${script_dir}")"
  if [ -n "${manifest}" ]; then
    printf '%s\n' "${manifest}"
    return 0
  fi

  manager="$(_thyx_package_manager || true)"
  local deps_file="deps.generic"

  case "${manager}" in
    pacman) deps_file="deps.arch" ;;
    dnf)    deps_file="deps.fedora" ;;
    zypper) deps_file="deps.opensuse-tumbleweed" ;;
    apk)    deps_file="deps.alpine-edge" ;;
    emerge) deps_file="deps.gentoo" ;;
  esac

  printf '%s/data/%s\n' "${script_dir}" "${deps_file}"
}

_thyx_manifest_from_map() {
  local script_dir="${1:?}" candidate pattern manifest
  local map_file="${script_dir}/data/deps.map"
  [ -f "${map_file}" ] || _thyx_die "dependency map missing: ${map_file}"

  while IFS= read -r candidate; do
    while read -r pattern manifest; do
      if [[ "${candidate}" == ${pattern} ]]; then
        printf '%s/data/%s\n' "${script_dir}" "${manifest}"
        return 0
      fi
    done < <(_thyx_read_clean "${map_file}")
  done < <(_thyx_os_candidates)

  return 0
}

_thyx_os_candidates() {
  local id version_codename version_id

  id="$(_thyx_os_field ID || true)"
  version_codename="$(_thyx_os_field VERSION_CODENAME || true)"
  version_id="$(_thyx_os_field VERSION_ID || true)"

  [ -n "${id}" ] || return 0
  [ -n "${version_codename}" ] && printf '%s:%s\n' "${id}" "${version_codename}"
  [ -n "${version_id}" ] && printf '%s:%s\n' "${id}" "${version_id}"
  printf '%s:*\n' "${id}"
}

_thyx_os_field() {
  local key="${1:?}"
  [ -r /etc/os-release ] || return 0
  awk -F= -v key="${key}" '$1 == key { gsub(/^"|"$/, "", $2); print $2; exit }' /etc/os-release
}

_thyx_package_manager() {
  local pm pm_cmd
  for pm in apt-get:apt dnf:dnf pacman:pacman zypper:zypper apk:apk emerge:emerge; do
    pm_cmd="${pm%:*}"
    if command -v "${pm_cmd}" >/dev/null 2>&1; then
      printf '%s\n' "${pm#*:}"
      return 0
    fi
  done
  return 1
}

_thyx_package_installed() {
  local package="${1:?}"
  local manager="$(_thyx_package_manager || true)"

  case "${manager}" in
    apt)    dpkg-query -W -f='${Status}\n' "${package}" 2>/dev/null | grep -qE '^install ok installed$' ;;
    dnf)    rpm -q "${package}" >/dev/null 2>&1 ;;
    pacman) pacman -Q "${package}" >/dev/null 2>&1 ;;
    zypper) rpm -q "${package}" >/dev/null 2>&1 || rpm -q --whatprovides "${package}" >/dev/null 2>&1 ;;
    apk)    apk info -e "${package}" >/dev/null 2>&1 ;;
    emerge) portageq has_version / "${package}" >/dev/null 2>&1 ;;
    *)      return 1 ;;
  esac
}

_thyx_missing_packages() {
  local manifest="${1:?}"
  local -n missing_ref="${2:?}"
  local package

  while IFS= read -r package; do
    _thyx_package_installed "${package}" || missing_ref+=("${package}")
  done < <(_thyx_read_clean "${manifest}")
}

_thyx_gentoo_portage_tree_required() {
  local manager="${1:-}"

  [ "${manager}" = "emerge" ] || return 0
  [ -d /var/db/repos/gentoo ] && return 0

  _thyx_die "Gentoo Portage tree missing: /var/db/repos/gentoo
Run emerge --sync first, or use a container/image with gentoo/portage mounted at /var/db/repos/gentoo."
}

_thyx_run_package_install() {
  local manager="${1:?}"
  shift
  [ "${#}" -gt 0 ] || return 0

  case "${manager}" in
    apt)
      _thyx_run apt-get update
      _thyx_run apt-get install -y --no-install-recommends "$@" ;;
    dnf)
      _thyx_run dnf -y install "$@" ;;
    pacman)
      _thyx_run pacman -Syu --noconfirm --needed "$@" ;;
    zypper)
      _thyx_run zypper --non-interactive refresh
      _thyx_run zypper --non-interactive install --no-recommends "$@" ;;
    apk)
      _thyx_run apk update
      _thyx_run apk add --no-cache "$@" ;;
    emerge)
      _thyx_run emerge --oneshot --noreplace "$@" ;;
    *) _thyx_die "unsupported package manager" ;;
  esac
}

_thyx_has_runtime_dep_failure() {
  local dep
  for dep in "${THYX_MISSING_DEPS[@]}"; do
    if [[ "${dep}" == package:* || "${dep}" == sddm\ greeter:* ]]; then
      return 0
    fi
  done
  return 1
}

_thyx_print_package_hint_file() {
  local label="${1:?}" file="${2:?}" package
  [ -f "${file}" ] || return 0

  printf '%s:\n' "${label}"
  while IFS= read -r package; do
    printf '  %s\n' "${package}"
  done < <(_thyx_read_clean "${file}")
  printf '\n'
}

_thyx_print_supported_patterns() {
  local map="${1:?}" pattern manifest
  [ -f "${map}" ] || return 0

  printf '%s\n' "supported distro patterns:"
  while read -r pattern manifest; do
    printf '  %s\n' "${pattern}"
  done < <(_thyx_read_clean "${map}")
  printf '\n'
}

_thyx_print_unsupported_distro() {
  local script_dir="${1:?}"

  printf '\nunsupported distro\n'
  printf '  detected ID: %s\n' "$(_thyx_os_field ID || true)"
  printf '  detected VERSION_ID: %s\n' "$(_thyx_os_field VERSION_ID || true)"
  printf '  detected VERSION_CODENAME: %s\n' "$(_thyx_os_field VERSION_CODENAME || true)"
  printf '  detected UBUNTU_CODENAME: %s\n\n' "$(_thyx_os_field UBUNTU_CODENAME || true)"

  _thyx_print_supported_patterns "${script_dir}/data/deps.map"
  _thyx_print_package_hint_file "deps.generic" "${script_dir}/data/deps.generic"
}

_thyx_print_runtime_package_hints() {
  local script_dir="${1:?}" manifest
  manifest="$(_thyx_prepare_runtime_manifest "${script_dir}")"
  printf '%s\n\n' "install the matching deps with your distro package manager."
  _thyx_print_package_hint_file "$(basename "${manifest}")" "${manifest}"
}

_thyx_report_missing_deps() {
  local script_dir="${1:-}" dep
  [ "${#THYX_MISSING_DEPS[@]}" -gt 0 ] || return 0

  printf '\n%s\n\n' "missing dependencies"
  for dep in "${THYX_MISSING_DEPS[@]}"; do
    printf '  - %s\n' "${dep}"
  done
  printf '\n'

  if [ -n "${script_dir}" ] && _thyx_has_runtime_dep_failure; then
    _thyx_print_runtime_package_hints "${script_dir}"
  fi
  _thyx_die "dependency check failed"
}