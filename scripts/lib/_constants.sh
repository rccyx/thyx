#!/usr/bin/env bash
# shellcheck disable=SC2034

THYX_THEME_ID="thyx"
THYX_THEME_DST="/usr/share/sddm/themes/${THYX_THEME_ID}"
THYX_FONTS_DST="/usr/local/share/fonts/${THYX_THEME_ID}"

THYX_SDDM_CONF="/etc/sddm.conf"
THYX_SDDM_CONF_BACK="${THYX_SDDM_CONF}.thyx-back"
THYX_SDDM_CONF_D_DIR="/etc/sddm.conf.d"
THYX_DROPIN="${THYX_SDDM_CONF_D_DIR}/zzzzzz-${THYX_THEME_ID}.conf"

THYX_HOME="${HOME:-}"
THYX_CACHE_DIR="${XDG_CACHE_HOME:-${THYX_HOME}/.cache}/thyx"
THYX_TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

THYX_AUTO_YES=0
THYX_LOG_FILE=""
THYX_LOG_PREFIX="thyx"
THYX_REPO_DIR=""
THYX_SUDO=()
