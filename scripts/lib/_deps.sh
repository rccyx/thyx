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
    _thyx_require_command "${cmd}"
  done < "${file}"
}

_thyx_dpkg_package_installed() {
  local package="${1:?}"

  dpkg-query -W -f='${Status}\n' "${package}" 2>/dev/null | grep -qE '^install ok installed$'
}

_thyx_pacman_package_installed() {
  local package="${1:?}"

  pacman -Q "${package}" >/dev/null 2>&1
}

_thyx_rpm_package_installed() {
  local package="${1:?}"

  rpm -q "${package}" >/dev/null 2>&1
}

_thyx_require_package_manifest() {
  local checker="${1:?}"
  local file="${2:?}"
  local package

  [ -f "${file}" ] || _thyx_die "dependency manifest missing: ${file}"

  while IFS= read -r package || [ -n "${package}" ]; do
    [ -n "${package}" ] || continue
    "${checker}" "${package}" || THYX_MISSING_DEPS+=("package: ${package}")
  done < "${file}"
}

_thyx_require_runtime_packages() {
  local script_dir="${1:?}"

  if command -v dpkg-query >/dev/null 2>&1; then
    _thyx_require_package_manifest _thyx_dpkg_package_installed "${script_dir}/data/deps.debian"
    return 0
  fi

  if command -v pacman >/dev/null 2>&1; then
    _thyx_require_package_manifest _thyx_pacman_package_installed "${script_dir}/data/deps.arch"
    return 0
  fi

  if command -v rpm >/dev/null 2>&1; then
    _thyx_require_package_manifest _thyx_rpm_package_installed "${script_dir}/data/deps.fedora"
    return 0
  fi
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

_thyx_print_package_hint_file() {
  local label="${1:?}"
  local file="${2:?}"

  [ -f "${file}" ] || return 0

  printf '%s\n' "${label}:"
  sed '/^[[:space:]]*$/d' "${file}" | sed 's/^/  /'
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
    printf ' %s' "${package}"
  done < "${file}"
  printf '\n\n'
}

_thyx_print_runtime_package_hints() {
  local script_dir="${1:?}"

  printf '%s\n\n' "install the matching deps with your distro package manager."
  _thyx_print_package_install_hint "debian/ubuntu" "sudo apt install" "${script_dir}/data/deps.debian"
  _thyx_print_package_install_hint "arch" "sudo pacman -S" "${script_dir}/data/deps.arch"
  _thyx_print_package_install_hint "fedora" "sudo dnf install" "${script_dir}/data/deps.fedora"
  _thyx_print_package_hint_file "generic" "${script_dir}/data/deps.generic"
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