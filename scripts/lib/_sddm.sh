#!/usr/bin/env bash

_thyx_theme_current_from_file() {
  local file="${1:?}"

  [ -f "${file}" ] || return 0

  awk '
    BEGIN { in_theme = 0 }
    /^\[Theme\]/ { in_theme = 1; next }
    /^\[/ { in_theme = 0 }
    in_theme && /^[[:space:]]*Current[[:space:]]*=/ {
      split($0, parts, "=")
      gsub(/^[ \t"]+|[ \t"]+$/, "", parts[2])
      print parts[2]
      exit
    }
  ' "${file}" 2>/dev/null || true
}

_thyx_effective_theme() {
  local current=""
  local next
  local file

  shopt -s nullglob
  for file in "${THYX_SDDM_CONF}" "${THYX_SDDM_CONF_D_DIR}"/*.conf; do
    [ -f "${file}" ] || continue
    next="$(_thyx_theme_current_from_file "${file}" || true)"
    [ -n "${next}" ] && current="${next}"
  done
  shopt -u nullglob

  printf '%s\n' "${current}"
}

_thyx_effective_theme_debug() {
  local current=""
  local next
  local file

  shopt -s nullglob
  for file in "${THYX_SDDM_CONF}" "${THYX_SDDM_CONF_D_DIR}"/*.conf; do
    [ -f "${file}" ] || continue
    next="$(_thyx_theme_current_from_file "${file}" || true)"
    if [ -n "${next}" ]; then
      current="${next}"
      printf 'wins so far: %s <- %s\n' "${current}" "${file}"
    fi
  done
  shopt -u nullglob

  printf 'effective Current=%s\n' "${current}"
}

_thyx_write_sddm_dropin() {
  local tmp

  _thyx_run mkdir -p -- "${THYX_SDDM_CONF_D_DIR}"
  tmp="$(mktemp)"
  printf '[Theme]\nCurrent=%s\n' "${THYX_THEME_ID}" > "${tmp}"
  _thyx_run install -m 0644 -- "${tmp}" "${THYX_DROPIN}"
  rm -f -- "${tmp}"
}

_thyx_select_sddm_theme() {
  local current

  _thyx_step "sddm"
  _thyx_write_sddm_dropin

  current="$(_thyx_effective_theme)"
  if [ "${current}" != "${THYX_THEME_ID}" ]; then
    _thyx_effective_theme_debug
    _thyx_die "effective SDDM theme is ${current:-empty}, expected ${THYX_THEME_ID}"
  fi

  _thyx_ok "sddm theme selected"
}

_thyx_remove_sddm_selection() {
  local path

  _thyx_step "sddm selection"
  _thyx_remove_one "${THYX_DROPIN}"

  shopt -s nullglob
  for path in "${THYX_SDDM_CONF_D_DIR}"/*"${THYX_THEME_ID}"*.conf "${THYX_SDDM_CONF_D_DIR}"/*"${THYX_THEME_ID}"*.conf.*.bak; do
    _thyx_remove_one "${path}"
  done

  for path in "${THYX_SDDM_CONF}".[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9].bak; do
    _thyx_remove_one "${path}"
  done
  shopt -u nullglob

  _thyx_ok "sddm selection removed"
}

_thyx_theme_dir_exists() {
  local name="${1:?}"
  local dir="/usr/share/sddm/themes/${name}"

  [ -d "${dir}" ] || return 1
  [ -f "${dir}/metadata.desktop" ] && return 0
  [ -f "${dir}/Main.qml" ] && return 0

  return 1
}

_thyx_pick_fallback_theme() {
  local preferred=(breeze breeze-dark breeze-light elarun maldives maya debian)
  local theme
  local dir

  for theme in "${preferred[@]}"; do
    if [ "${theme}" != "${THYX_THEME_ID}" ] && _thyx_theme_dir_exists "${theme}"; then
      printf '%s\n' "${theme}"
      return 0
    fi
  done

  shopt -s nullglob
  for dir in /usr/share/sddm/themes/*; do
    [ -d "${dir}" ] || continue
    theme="$(basename "${dir}")"
    [ "${theme}" = "${THYX_THEME_ID}" ] && continue
    if _thyx_theme_dir_exists "${theme}"; then
      printf '%s\n' "${theme}"
      shopt -u nullglob
      return 0
    fi
  done
  shopt -u nullglob

  return 1
}

_thyx_remove_current_if_equals() {
  local bad="${1:?}"
  local current
  local tmp

  [ -f "${THYX_SDDM_CONF}" ] || return 0

  current="$(_thyx_theme_current_from_file "${THYX_SDDM_CONF}" || true)"
  [ "${current}" = "${bad}" ] || return 0

  tmp="$(mktemp)"
  awk -v bad="${bad}" '
    BEGIN { in_theme = 0 }
    /^\[Theme\][[:space:]]*$/ { in_theme = 1; print; next }
    /^\[/ { in_theme = 0; print; next }
    {
      if (in_theme == 1 && $0 ~ /^[[:space:]]*Current[[:space:]]*=/) {
        split($0, parts, "=")
        value = parts[2]
        gsub(/^[ \t"]+|[ \t"]+$/, "", value)
        if (value == bad) {
          next
        }
      }
      print
    }
  ' "${THYX_SDDM_CONF}" > "${tmp}"

  _thyx_run install -m 0644 -- "${tmp}" "${THYX_SDDM_CONF}"
  rm -f -- "${tmp}"
}

_thyx_set_theme_current_in_main_conf() {
  local theme="${1:?}"
  local tmp

  tmp="$(mktemp)"

  if [ -f "${THYX_SDDM_CONF}" ]; then
    awk -v theme="${theme}" '
      BEGIN { in_theme = 0; seen_theme = 0; wrote_current = 0 }
      /^\[Theme\][[:space:]]*$/ {
        seen_theme = 1
        in_theme = 1
        print
        next
      }
      /^\[/ {
        if (in_theme == 1 && wrote_current == 0) {
          print "Current=" theme
          wrote_current = 1
        }
        in_theme = 0
        print
        next
      }
      {
        if (in_theme == 1 && $0 ~ /^[[:space:]]*Current[[:space:]]*=/) {
          print "Current=" theme
          wrote_current = 1
          next
        }
        print
      }
      END {
        if (seen_theme == 1 && wrote_current == 0) {
          print "Current=" theme
        } else if (seen_theme == 0) {
          print ""
          print "[Theme]"
          print "Current=" theme
        }
      }
    ' "${THYX_SDDM_CONF}" > "${tmp}"
  else
    printf '[Theme]\nCurrent=%s\n' "${theme}" > "${tmp}"
  fi

  _thyx_run install -m 0644 -- "${tmp}" "${THYX_SDDM_CONF}"
  rm -f -- "${tmp}"
}

_thyx_restore_legacy_sddm_conf() {
  local fallback

  _thyx_step "sddm restore"

  if [ -e "${THYX_SDDM_CONF_BACK}" ]; then
    if [ -f "${THYX_SDDM_CONF_BACK}" ]; then
      _thyx_run install -m 0644 -- "${THYX_SDDM_CONF_BACK}" "${THYX_SDDM_CONF}"
      _thyx_run rm -f -- "${THYX_SDDM_CONF_BACK}"
      _thyx_ok "restored ${THYX_SDDM_CONF}"
      return 0
    fi

    _thyx_remove_one "${THYX_SDDM_CONF_BACK}"
    _thyx_ok "removed invalid legacy backup"
    return 0
  fi

  if [ "$(_thyx_theme_current_from_file "${THYX_SDDM_CONF}" || true)" != "${THYX_THEME_ID}" ]; then
    _thyx_ok "main config does not select ${THYX_THEME_ID}"
    return 0
  fi

  fallback="$(_thyx_pick_fallback_theme || true)"
  if [ -n "${fallback}" ]; then
    _thyx_set_theme_current_in_main_conf "${fallback}"
    _thyx_ok "fallback selected: ${fallback}"
    return 0
  fi

  _thyx_remove_current_if_equals "${THYX_THEME_ID}"
  _thyx_ok "cleared Current=${THYX_THEME_ID}"
}
