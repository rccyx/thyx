#!/usr/bin/env bash

THYX_MISSING_DEPS=()

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
  local file="${1:?}"
  local cmd

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

_thyx_has_word() {
  local word="${1:?}"
  local haystack="${2:-}"

  case " ${haystack} " in
    *" ${word} "*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

_thyx_runtime_manifest() {
  local script_dir="${1:?}"
  local id
  local id_like
  local version_id
  local version_codename
  local ubuntu_codename

  id="$(_thyx_os_field ID || true)"
  id_like="$(_thyx_os_field ID_LIKE || true)"
  version_id="$(_thyx_os_field VERSION_ID || true)"
  version_codename="$(_thyx_os_field VERSION_CODENAME || true)"
  ubuntu_codename="$(_thyx_os_field UBUNTU_CODENAME || true)"

  case "${id}:${version_codename}" in
    debian:trixie)
      printf '%s\n' "${script_dir}/data/deps.debian-trixie"
      return 0
      ;;
    ubuntu:noble)
      printf '%s\n' "${script_dir}/data/deps.ubuntu-noble"
      return 0
      ;;
    ubuntu:resolute)
      printf '%s\n' "${script_dir}/data/deps.ubuntu-resolute"
      return 0
      ;;
  esac

  case "${id}:${version_id}" in
    debian:13*)
      printf '%s\n' "${script_dir}/data/deps.debian-trixie"
      return 0
      ;;
    ubuntu:24.04)
      printf '%s\n' "${script_dir}/data/deps.ubuntu-noble"
      return 0
      ;;
    ubuntu:26.04)
      printf '%s\n' "${script_dir}/data/deps.ubuntu-resolute"
      return 0
      ;;
    linuxmint:22*)
      printf '%s\n' "${script_dir}/data/deps.ubuntu-noble"
      return 0
      ;;
    fedora:*)
      printf '%s\n' "${script_dir}/data/deps.fedora"
      return 0
      ;;
    arch:*)
      printf '%s\n' "${script_dir}/data/deps.arch"
      return 0
      ;;
    opensuse-tumbleweed:*)
      printf '%s\n' "${script_dir}/data/deps.opensuse-tumbleweed"
      return 0
      ;;
    alpine:*)
      printf '%s\n' "${script_dir}/data/deps.alpine-edge"
      return 0
      ;;
    gentoo:*)
      printf '%s\n' "${script_dir}/data/deps.gentoo"
      return 0
      ;;
  esac

  case "${ubuntu_codename}" in
    noble)
      printf '%s\n' "${script_dir}/data/deps.ubuntu-noble"
      return 0
      ;;
    resolute)
      printf '%s\n' "${script_dir}/data/deps.ubuntu-resolute"
      return 0
      ;;
  esac

  if _thyx_has_word arch "${id_like}"; then
    printf '%s\n' "${script_dir}/data/deps.arch"
    return 0
  fi

  if _thyx_has_word fedora "${id_like}"; then
    printf '%s\n' "${script_dir}/data/deps.fedora"
    return 0
  fi

  if command -v pacman >/dev/null 2>&1; then
    printf '%s\n' "${script_dir}/data/deps.arch"
    return 0
  fi

  if command -v dnf >/dev/null 2>&1; then
    printf '%s\n' "${script_dir}/data/deps.fedora"
    return 0
  fi

  printf '%s\n' "${script_dir}/data/deps.generic"
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
  local package="${1:?}"
  local manager

  manager="$(_thyx_package_manager || true)"

  case "${manager}" in
    apt)
      dpkg-query -W -f='${Status}\n' "${package}" 2>/dev/null | grep -qE '^install ok installed$'
      ;;
    dnf|zypper)
      rpm -q "${package}" >/dev/null 2>&1
      ;;
    pacman)
      pacman -Q "${package}" >/dev/null 2>&1
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
      _thyx_run emerge --oneshot --noreplace "$@"
      ;;
    *)
      _thyx_die "unsupported package manager"
      ;;
  esac
}

_thyx_install_runtime_deps() {
  local script_dir="${1:?}"
  local manifest
  local manager
  local package
  local missing=()

  _thyx_step "packages"

  manifest="$(_thyx_runtime_manifest "${script_dir}")"

  if [ "$(basename "${manifest}")" = "deps.generic" ]; then
    _thyx_print_package_hint_file "generic" "${manifest}"
    _thyx_die "unsupported distro: install the generic dependencies manually"
  fi

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

  _thyx_info "manifest: ${manifest}"
  _thyx_run_package_install "${manager}" "${missing[@]}"
  _thyx_ok "runtime packages installed"
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
  local script_dir="${1:?}"
  local manifest

  manifest="$(_thyx_runtime_manifest "${script_dir}")"

  if [ "$(basename "${manifest}")" = "deps.generic" ]; then
    return 0
  fi

  _thyx_require_package_manifest "${manifest}"
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
  local label="${1:?}"
  local file="${2:?}"
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

_thyx_print_package_install_hint() {
  local label="${1:?}"
  local command="${2:?}"
  local file="${3:?}"
  local package

  [ -f "${file}" ] || return 0

  printf '%s\n' "${label}:"
  printf '  %s' "${command}"
  while IFS= read -r package || [ -n "${package}" ]; do
    [ -n "${package}" ] || continue

    case "${package}" in
      \#*)
        continue
        ;;
    esac

    printf ' %s' "${package}"
  done < "${file}"
  printf '\n\n'
}

_thyx_print_runtime_package_hints() {
  local script_dir="${1:?}"

  printf '%s\n\n' "install the matching deps with your distro package manager."

  _thyx_print_package_install_hint "debian trixie" "sudo apt-get install" "${script_dir}/data/deps.debian-trixie"
  _thyx_print_package_install_hint "ubuntu 24.04 / mint 22" "sudo apt-get install" "${script_dir}/data/deps.ubuntu-noble"
  _thyx_print_package_install_hint "ubuntu 26.04" "sudo apt-get install" "${script_dir}/data/deps.ubuntu-resolute"
  _thyx_print_package_install_hint "arch" "sudo pacman -S" "${script_dir}/data/deps.arch"
  _thyx_print_package_install_hint "fedora" "sudo dnf install" "${script_dir}/data/deps.fedora"
  _thyx_print_package_install_hint "opensuse tumbleweed" "sudo zypper install" "${script_dir}/data/deps.opensuse-tumbleweed"
  _thyx_print_package_install_hint "alpine edge" "sudo apk add" "${script_dir}/data/deps.alpine-edge"
  _thyx_print_package_install_hint "gentoo" "sudo emerge --oneshot --noreplace" "${script_dir}/data/deps.gentoo"
  _thyx_print_package_hint_file "generic" "${script_dir}/data/deps.generic"
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
