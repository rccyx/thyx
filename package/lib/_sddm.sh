#!/usr/bin/env bash

_thyx_theme_current_from_file() {
  local file="${1:?}"

  [ -f "${file}" ] || return 0

  awk '
    BEGIN { in_theme = 0 }

    /^[[:space:]]*\[Theme\][[:space:]]*$/ {
      in_theme = 1
      next
    }

    /^[[:space:]]*\[/ {
      in_theme = 0
      next
    }

    in_theme && /^[[:space:]]*Current[[:space:]]*=/ {
      sub(/^[^=]*=/, "")
      gsub(/^[ \t]+|[ \t]+$/, "")
      print
      exit
    }
  ' "${file}" 2>/dev/null || true
}

_thyx_backup_sddm_conf_once() {
  [ -f "${THYX_SDDM_CONF}" ] || return 0
  [ ! -e "${THYX_SDDM_CONF_BACK}" ] || return 0

  _thyx_run cp -p -- "${THYX_SDDM_CONF}" "${THYX_SDDM_CONF_BACK}"
}

_thyx_set_sddm_current() {
  local tmp

  _thyx_backup_sddm_conf_once
  tmp="$(mktemp)"

  if [ -f "${THYX_SDDM_CONF}" ]; then
    awk -v theme="${THYX_THEME_ID}" '
      BEGIN {
        in_theme = 0
        seen_theme = 0
        wrote_current = 0
      }

      /^[[:space:]]*\[Theme\][[:space:]]*$/ {
        seen_theme = 1
        in_theme = 1
        print
        next
      }

      /^[[:space:]]*\[/ {
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
        }

        if (seen_theme == 0) {
          print "[Theme]"
          print "Current=" theme
        }
      }
    ' "${THYX_SDDM_CONF}" > "${tmp}"
  else
    printf '[Theme]\nCurrent=%s\n' "${THYX_THEME_ID}" > "${tmp}"
  fi

  _thyx_run install -m 0644 -- "${tmp}" "${THYX_SDDM_CONF}"
  rm -f -- "${tmp}"
}

_thyx_select_sddm_theme() {
  local current

  _thyx_step "sddm"
  _thyx_set_sddm_current

  current="$(_thyx_theme_current_from_file "${THYX_SDDM_CONF}")"
  [ "${current}" = "${THYX_THEME_ID}" ] || _thyx_die "${THYX_SDDM_CONF} selects ${current:-empty}, expected ${THYX_THEME_ID}"

  _thyx_ok "sddm theme selected"
}

_thyx_restore_sddm_conf_backup() {
  [ -f "${THYX_SDDM_CONF_BACK}" ] || return 1

  _thyx_run install -m 0644 -- "${THYX_SDDM_CONF_BACK}" "${THYX_SDDM_CONF}"
  _thyx_run rm -f -- "${THYX_SDDM_CONF_BACK}"
  return 0
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

    /^[[:space:]]*\[Theme\][[:space:]]*$/ {
      in_theme = 1
      print
      next
    }

    /^[[:space:]]*\[/ {
      in_theme = 0
      print
      next
    }

    {
      if (in_theme == 1 && $0 ~ /^[[:space:]]*Current[[:space:]]*=/) {
        value = $0
        sub(/^[^=]*=/, "", value)
        gsub(/^[ \t]+|[ \t]+$/, "", value)

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

_thyx_remove_sddm_selection() {
  _thyx_step "sddm selection"

  _thyx_restore_sddm_conf_backup || _thyx_remove_current_if_equals "${THYX_THEME_ID}"

  _thyx_ok "sddm selection removed"
}
