#!/usr/bin/env bash

THYX_MISSING_DEPS=()
THYX_RUNTIME_MANIFEST=""

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

  if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    _thyx_require_command sudo
  fi

  if _thyx_source_has_fonts; then
    _thyx_require_command fc-cache
  fi

  _thyx_report_missing_deps "${script_dir}"
  _thyx_ok "deps ok"
}

_thyx_check_uninstall_deps() {
  local script_dir="${1:?}"

  THYX_MISSING_DEPS=()

  _thyx_step "deps"
  _thyx_require_commands_file "${script_dir}/data/uninstall.commands"

  if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    _thyx_require_command sudo
  fi

  if [ -d "${THYX_FONTS_DST}" ]; then
    _thyx_require_command fc-cache
  fi

  _thyx_report_missing_deps
  _thyx_ok "deps ok"
}

_thyx_install_runtime_deps() {
  local script_dir="${1:?}"
  local manager
  local manifest
  local missing=()
  local package

  _thyx_step "packages"

  manifest="$(_thyx_prepare_runtime_manifest "${script_dir}")"
  _thyx_info "manifest: ${manifest}"

  manager="$(_thyx_package_manager || true)"
  [ -n "${manager}" ] || _thyx_die "no supported package manager found"

  while IFS= read -r package || [ -n "${package}" ]; do
    [ -n "${package}" ] || continue
    missing+=("${package}")
  done < <(_thyx_missing_packages "${manifest}")

  if [ "${#missing[@]}" -eq 0 ]; then
    _thyx_ok "runtime packages already installed"
    return 0
  fi

  _thyx_run_package_install "${manager}" "${missing[@]}"
  _thyx_ok "runtime packages installed"
}

_thyx_prepare_runtime_manifest() {
  local manifest
  local script_dir="${1:?}"

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
  local cmd
  local file="${1:?}"

  [ -f "${file}" ] || _thyx_die "dependency manifest missing: ${file}"

  while IFS= read -r cmd || [ -n "${cmd}" ]; do
    [ -n "${cmd}" ] || continue

    case "${cmd}" in
      \#*)
        continue
        ;;
    esac

    _thyx_require_command "${cmd}"
  done < "${file}"
}

_thyx_require_package_manifest() {
  local file="${1:?}"
  local package

  [ -f "${file}" ] || _thyx_die "dependency manifest missing: ${file}"

  while IFS= read -r package || [ -n "${package}" ]; do
    [ -n "${package}" ] || continue
    _thyx_package_installed "${package}" || THYX_MISSING_DEPS+=("package: ${package}")
  done < <(_thyx_manifest_packages "${file}")
}

_thyx_require_runtime_packages() {
  local manifest
  local script_dir="${1:?}"

  manifest="$(_thyx_prepare_runtime_manifest "${script_dir}")"
  _thyx_require_package_manifest "${manifest}"
}

_thyx_runtime_manifest() {
  local script_dir="${1:?}"
  local manifest
  local manager

  manifest="$(_thyx_manifest_from_map "${script_dir}")"
  if [ -n "${manifest}" ]; then
    printf '%s\n' "${manifest}"
    return 0
  fi

  manager="$(_thyx_package_manager || true)"
  case "${manager}" in
    pacman)
      printf '%s\n' "${script_dir}/data/deps.arch"
      ;;
    dnf)
      printf '%s\n' "${script_dir}/data/deps.fedora"
      ;;
    zypper)
      printf '%s\n' "${script_dir}/data/deps.opensuse-tumbleweed"
      ;;
    apk)
      printf '%s\n' "${script_dir}/data/deps.alpine-edge"
      ;;
    emerge)
      printf '%s\n' "${script_dir}/data/deps.gentoo"
      ;;
    *)
      printf '%s\n' "${script_dir}/data/deps.generic"
      ;;
  esac
}

_thyx_manifest_from_map() {
  local candidate
  local manifest
  local pattern
  local script_dir="${1:?}"

  [ -f "${script_dir}/data/deps.map" ] || _thyx_die "dependency map missing: ${script_dir}/data/deps.map"

  while IFS= read -r candidate || [ -n "${candidate}" ]; do
    [ -n "${candidate}" ] || continue

    while read -r pattern manifest; do
      [ -n "${pattern}" ] || continue

      case "${pattern}" in
        \#*)
          continue
          ;;
      esac

      case "${candidate}" in
        ${pattern})
          printf '%s\n' "${script_dir}/data/${manifest}"
          return 0
          ;;
      esac
    done < "${script_dir}/data/deps.map"
  done < <(_thyx_os_candidates)

  return 0
}

_thyx_os_candidates() {
  local id
  local ubuntu_codename
  local version_codename
  local version_id

  id="$(_thyx_os_field ID || true)"
  version_codename="$(_thyx_os_field VERSION_CODENAME || true)"
  version_id="$(_thyx_os_field VERSION_ID || true)"
  ubuntu_codename="$(_thyx_os_field UBUNTU_CODENAME || true)"

  [ -n "${id}" ] || return 0
  [ -n "${version_codename}" ] && printf '%s:%s\n' "${id}" "${version_codename}"
  [ -n "${version_id}" ] && printf '%s:%s\n' "${id}" "${version_id}"
  printf '%s:*\n' "${id}"
  [ -n "${ubuntu_codename}" ] && printf 'ubuntu:%s\n' "${ubuntu_codename}"
}

_thyx_os_field() {
  local key="${1:?}"

  [ -r /etc/os-release ] || return 0

  awk -F= -v key="${key}" '
    $1 == key {
      gsub(/^"|"$/, "", $2)
      print $2
      exit
    }
  ' /etc/os-release
}

_thyx_package_manager() {
  if command -v apt-get >/dev/null 2>&1; then
    printf '%s\n' apt
    return 0
  fi

  if command -v dnf >/dev/null 2>&1; then
    printf '%s\n' dnf
    return 0
  fi

  if command -v pacman >/dev/null 2>&1; then
    printf '%s\n' pacman
    return 0
  fi

  if command -v zypper >/dev/null 2>&1; then
    printf '%s\n' zypper
    return 0
  fi

  if command -v apk >/dev/null 2>&1; then
    printf '%s\n' apk
    return 0
  fi

  if command -v emerge >/dev/null 2>&1; then
    printf '%s\n' emerge
    return 0
  fi

  return 1
}

_thyx_package_installed() {
  local manager
  local package="${1:?}"

  manager="$(_thyx_package_manager || true)"

  case "${manager}" in
    apt)
      dpkg-query -W -f='${Status}\n' "${package}" 2>/dev/null | grep -qE '^install ok installed$'
      ;;
    dnf)
      rpm -q "${package}" >/dev/null 2>&1
      ;;
    pacman)
      pacman -Q "${package}" >/dev/null 2>&1
      ;;
    zypper)
      rpm -q "${package}" >/dev/null 2>&1 || rpm -q --whatprovides "${package}" >/dev/null 2>&1
      ;;
    apk)
      apk info -e "${package}" >/dev/null 2>&1
      ;;
    emerge)
      portageq has_version / "${package}" >/dev/null 2>&1
      ;;
    *)
      return 1
      ;;
  esac
}

_thyx_manifest_packages() {
  local file="${1:?}"
  local package

  [ -f "${file}" ] || _thyx_die "dependency manifest missing: ${file}"

  while IFS= read -r package || [ -n "${package}" ]; do
    [ -n "${package}" ] || continue

    case "${package}" in
      \#*)
        continue
        ;;
    esac

    printf '%s\n' "${package}"
  done < "${file}"
}

_thyx_missing_packages() {
  local file="${1:?}"
  local package

  while IFS= read -r package || [ -n "${package}" ]; do
    [ -n "${package}" ] || continue
    _thyx_package_installed "${package}" || printf '%s\n' "${package}"
  done < <(_thyx_manifest_packages "${file}")
}

_thyx_run_package_install() {
  local manager="${1:?}"
  shift

  [ "${#}" -gt 0 ] || return 0

  case "${manager}" in
    apt)
      _thyx_run apt-get update
      _thyx_run apt-get install -y --no-install-recommends "$@"
      ;;
    dnf)
      _thyx_run dnf -y install "$@"
      ;;
    pacman)
      _thyx_run pacman -Syu --noconfirm --needed "$@"
      ;;
    zypper)
      _thyx_run zypper --non-interactive refresh
      _thyx_run zypper --non-interactive install --no-recommends "$@"
      ;;
    apk)
      _thyx_run apk update
      _thyx_run apk add --no-cache "$@"
      ;;
    emerge)
      if [ ! -d /var/db/repos/gentoo ]; then
        _thyx_run emerge --sync
      fi

      _thyx_run emerge --oneshot --noreplace "$@"
      ;;
    *)
      _thyx_die "unsupported package manager"
      ;;
  esac
}

_thyx_has_runtime_dep_failure() {
  local dep

  for dep in "${THYX_MISSING_DEPS[@]}"; do
    case "${dep}" in
      package:*|sddm\ greeter:*)
        return 0
        ;;
    esac
  done

  return 1
}

_thyx_print_package_hint_file() {
  local file="${2:?}"
  local label="${1:?}"
  local package

  [ -f "${file}" ] || return 0

  printf '%s\n' "${label}:"
  while IFS= read -r package || [ -n "${package}" ]; do
    [ -n "${package}" ] || continue

    case "${package}" in
      \#*)
        continue
        ;;
    esac

    printf '  %s\n' "${package}"
  done < "${file}"
  printf '\n'
}

_thyx_print_supported_patterns() {
  local map="${1:?}"
  local manifest
  local pattern

  [ -f "${map}" ] || return 0

  printf '%s\n' "supported distro patterns:"
  while read -r pattern manifest; do
    [ -n "${pattern}" ] || continue

    case "${pattern}" in
      \#*)
        continue
        ;;
    esac

    printf '  %s\n' "${pattern}"
  done < "${map}"
  printf '\n'
}

_thyx_print_unsupported_distro() {
  local script_dir="${1:?}"

  printf '\n'
  printf '%s\n' "unsupported distro"
  printf '  detected ID: %s\n' "$(_thyx_os_field ID || true)"
  printf '  detected VERSION_ID: %s\n' "$(_thyx_os_field VERSION_ID || true)"
  printf '  detected VERSION_CODENAME: %s\n' "$(_thyx_os_field VERSION_CODENAME || true)"
  printf '  detected UBUNTU_CODENAME: %s\n' "$(_thyx_os_field UBUNTU_CODENAME || true)"
  printf '\n'

  _thyx_print_supported_patterns "${script_dir}/data/deps.map"
  _thyx_print_package_hint_file "deps.generic" "${script_dir}/data/deps.generic"
}

_thyx_print_runtime_package_hints() {
  local manifest
  local script_dir="${1:?}"

  manifest="$(_thyx_prepare_runtime_manifest "${script_dir}")"
  printf '%s\n\n' "install the matching deps with your distro package manager."
  _thyx_print_package_hint_file "$(basename "${manifest}")" "${manifest}"
}

_thyx_report_missing_deps() {
  local dep
  local script_dir="${1:-}"

  [ "${#THYX_MISSING_DEPS[@]}" -gt 0 ] || return 0

  printf '\n'
  printf '%s\n\n' "missing dependencies"

  for dep in "${THYX_MISSING_DEPS[@]}"; do
    [ -n "${dep}" ] || continue
    printf '  - %s\n' "${dep}"
  done

  printf '\n'
  if [ -n "${script_dir}" ] && _thyx_has_runtime_dep_failure; then
    _thyx_print_runtime_package_hints "${script_dir}"
  fi

  _thyx_die "dependency check failed"
}
