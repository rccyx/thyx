#!/usr/bin/env bash

_thyx_meta_get() {
  local key="${1:?}"
  local file="${2:?}"

  awk -F= -v k="${key}" '
    $0 ~ "^[[:space:]]*" k "[[:space:]]*=" {
      sub("^[[:space:]]*" k "[[:space:]]*=", "")
      gsub(/^[ \t"]+|[ \t"]+$/, "")
      print
      exit
    }
  ' "${file}" 2>/dev/null || true
}

_thyx_validate_repo_tree() {
  local root="${1:?}"
  local meta="${root}/metadata.desktop"

  [ -f "${meta}" ] || _thyx_die "metadata.desktop missing in ${root}"

  local name theme_id main_script config_file
  name="$(_thyx_meta_get Name "${meta}")"
  theme_id="$(_thyx_meta_get Theme-Id "${meta}")"
  main_script="$(_thyx_meta_get MainScript "${meta}")"
  config_file="$(_thyx_meta_get ConfigFile "${meta}")"

  [ "${theme_id}" = "${THYX_THEME_ID}" ] || _thyx_die "not ${THYX_THEME_ID}: Theme-Id=${theme_id:-missing} in ${meta}"
  [ "${name}" = "${THYX_THEME_ID}" ] || _thyx_die "not ${THYX_THEME_ID}: Name=${name:-missing} in ${meta}"
  [ "${main_script}" = "src/Main.qml" ] || _thyx_die "MainScript is ${main_script:-missing}, expected src/Main.qml in ${meta}"
  [ "${config_file}" = "theme.conf" ] || _thyx_die "ConfigFile is ${config_file:-missing}, expected theme.conf in ${meta}"
  [ -f "${root}/${main_script}" ] || _thyx_die "MainScript missing: ${root}/${main_script}"
  [ -f "${root}/${config_file}" ] || _thyx_die "ConfigFile missing: ${root}/${config_file}"
}

_thyx_find_repo() {
  local script_dir="${1:?}"
  local scripts_parent
  local cwd

  scripts_parent="$(cd "${script_dir}/.." && pwd -P)"
  cwd="$(pwd -P)"

  if [ -f "${scripts_parent}/metadata.desktop" ]; then
    _thyx_validate_repo_tree "${scripts_parent}"
    printf '%s\n' "${scripts_parent}"
    return 0
  fi

  if [ -f "${cwd}/metadata.desktop" ]; then
    _thyx_validate_repo_tree "${cwd}"
    printf '%s\n' "${cwd}"
    return 0
  fi

  _thyx_die "metadata.desktop not found from ${script_dir} or ${cwd}"
}