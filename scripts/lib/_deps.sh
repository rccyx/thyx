#!/usr/bin/env bash

THYX_MISSING_DEPS=()
THYX_MISSING_RUNTIME_DEPS=()
THYX_QML_ROOTS=()

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

_thyx_report_missing_deps() {
  local dep
  local script_dir="${1:-}"

  if [ "${#THYX_MISSING_DEPS[@]}" -eq 0 ] && [ "${#THYX_MISSING_RUNTIME_DEPS[@]}" -eq 0 ]; then
    return 0
  fi

  printf '\n'
  if [ "${#THYX_MISSING_DEPS[@]}" -gt 0 ]; then
    printf '%s\n\n' "missing dependencies"

    for dep in "${THYX_MISSING_DEPS[@]}"; do
      printf '  - %s\n' "${dep}"
    done

    printf '\n'
  fi

  if [ "${#THYX_MISSING_RUNTIME_DEPS[@]}" -gt 0 ]; then
    printf '%s\n\n' "missing qml runtime modules"

    for dep in "${THYX_MISSING_RUNTIME_DEPS[@]}"; do
      printf '  - %s\n' "${dep}"
    done

    printf '\n'
    if [ -n "${script_dir}" ]; then
      _thyx_print_runtime_package_hints "${script_dir}"
    fi
  fi

  _thyx_die "dependency check failed"
}

_thyx_add_qml_root() {
  local root="${1:-}"
  local existing

  [ -n "${root}" ] || return 0
  [ -d "${root}" ] || return 0

  for existing in "${THYX_QML_ROOTS[@]}"; do
    [ "${existing}" = "${root}" ] && return 0
  done

  THYX_QML_ROOTS+=("${root}")
}

_thyx_add_qml_path_list() {
  local paths="${1:-}"
  local entries=()
  local entry

  [ -n "${paths}" ] || return 0

  IFS=':' read -r -a entries <<< "${paths}"
  for entry in "${entries[@]}"; do
    _thyx_add_qml_root "${entry}"
  done
}

_thyx_add_qtpaths_qml_root() {
  local cmd="${1:?}"
  local root

  command -v "${cmd}" >/dev/null 2>&1 || return 0
  root="$("${cmd}" --query QT_INSTALL_QML 2>/dev/null || true)"
  _thyx_add_qml_root "${root}"
}

_thyx_collect_qml_roots() {
  _thyx_add_qml_path_list "${QML_IMPORT_PATH:-}"
  _thyx_add_qml_path_list "${QML2_IMPORT_PATH:-}"
  _thyx_add_qtpaths_qml_root qtpaths6
  _thyx_add_qtpaths_qml_root qtpaths
  _thyx_add_qml_root /usr/lib/qt6/qml
  _thyx_add_qml_root /usr/lib64/qt6/qml
  _thyx_add_qml_root /usr/share/qt6/qml
  _thyx_add_qml_root /usr/lib/qt/qml
  _thyx_add_qml_root /usr/lib64/qt/qml
  _thyx_add_qml_root /usr/share/qt/qml
}

_thyx_collect_source_qml_imports() {
  find "${THYX_REPO_DIR}/src" "${THYX_REPO_DIR}/ui" -type f -name '*.qml' -exec awk '
    $1 == "import" && $2 !~ /^"/ {
      major = ""

      if ($3 ~ /^[0-9]+([.][0-9]+)?$/) {
        split($3, version, ".")
        major = version[1]
      }

      if (major != "") {
        print $2 " " major
      } else {
        print $2
      }
    }
  ' {} + | sort -u
}

_thyx_qml_import_exists() {
  local import_name="${1:?}"
  local major="${2:-}"
  local rel="${import_name//./\/}"
  local root

  for root in "${THYX_QML_ROOTS[@]}"; do
    [ -d "${root}/${rel}" ] && return 0
    [ -f "${root}/${rel}/qmldir" ] && return 0

    if [ -n "${major}" ]; then
      [ -d "${root}/${rel}.${major}" ] && return 0
      [ -f "${root}/${rel}.${major}/qmldir" ] && return 0
    fi
  done

  return 1
}

_thyx_require_qml_imports_from_source() {
  local import_name
  local major

  _thyx_collect_qml_roots

  while read -r import_name major || [ -n "${import_name:-}" ]; do
    [ -n "${import_name:-}" ] || continue
    if ! _thyx_qml_import_exists "${import_name}" "${major:-}"; then
      THYX_MISSING_RUNTIME_DEPS+=("qml runtime: ${import_name}")
    fi
  done < <(_thyx_collect_source_qml_imports)
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
  THYX_MISSING_RUNTIME_DEPS=()

  _thyx_step "deps"
  _thyx_require_commands_file "${script_dir}/data/install.commands"
  _thyx_require_one_command "sddm greeter" sddm-greeter-qt6 sddm-greeter
  _thyx_require_qml_imports_from_source

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
  THYX_MISSING_RUNTIME_DEPS=()

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
