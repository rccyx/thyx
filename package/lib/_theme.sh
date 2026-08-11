#!/usr/bin/env bash

_thyx_source_has_fonts() {
  local fonts_src="${THYX_REPO_DIR}/fonts"

  [ -d "${fonts_src}" ] || return 1
  find -L "${fonts_src}" -type f \( -iname '*.otf' -o -iname '*.ttf' \) -print -quit | grep -q .
}

_thyx_make_live_config_user_writable() {
  local theme_conf="${THYX_THEME_DST}/theme.conf"

  [ -f "${theme_conf}" ] || return 0
  [ -n "${SUDO_UID:-}" ] || return 0
  [ -n "${SUDO_GID:-}" ] || return 0
  [ "${SUDO_UID}" != "0" ] || return 0

  _thyx_run chown "${SUDO_UID}:${SUDO_GID}" -- "${theme_conf}"
}

_thyx_remove_theme_staging() {
  _thyx_remove_one "${THYX_THEME_STAGE}"
  _thyx_remove_one "${THYX_THEME_PREVIOUS}"
}

_thyx_install_theme_atomic() {
  _thyx_step "theme"
  _thyx_validate_repo_tree "${THYX_REPO_DIR}"

  _thyx_info "staging to: ${THYX_THEME_STAGE}"
  _thyx_remove_theme_staging
  _thyx_run mkdir -p -- "${THYX_THEME_STAGE}"

  _thyx_run rsync -a --delete \
    --exclude '.git/' \
    --exclude '.github/' \
    --exclude 'assets/' \
    --exclude 'fonts/' \
    --exclude 'README.md' \
    --exclude '.qmllint.ini' \
    "${THYX_REPO_DIR}/" "${THYX_THEME_STAGE}/"

  _thyx_validate_repo_tree "${THYX_THEME_STAGE}"

  _thyx_info "activating: ${THYX_THEME_DST}"

  if [ -d "${THYX_THEME_DST}" ]; then
    _thyx_run mv -- "${THYX_THEME_DST}" "${THYX_THEME_PREVIOUS}"
  fi

  if ! _thyx_run mv -- "${THYX_THEME_STAGE}" "${THYX_THEME_DST}"; then
    _thyx_restore_theme_previous
    return 1
  fi

  if ! ( _thyx_validate_repo_tree "${THYX_THEME_DST}" ); then
    _thyx_remove_one "${THYX_THEME_DST}"
    _thyx_restore_theme_previous
    return 1
  fi

  _thyx_make_live_config_user_writable
  _thyx_remove_one "${THYX_THEME_PREVIOUS}"
  _thyx_ok "theme installed"
}

_thyx_restore_theme_previous() {
  if [ ! -e "${THYX_THEME_PREVIOUS}" ] && [ ! -L "${THYX_THEME_PREVIOUS}" ]; then
    return 0
  fi

  _thyx_warn "restoring previous theme"
  _thyx_remove_one "${THYX_THEME_DST}"
  _thyx_run mv -- "${THYX_THEME_PREVIOUS}" "${THYX_THEME_DST}"
}

_thyx_install_fonts() {
  local fonts_src="${THYX_REPO_DIR}/fonts"
  local font

  _thyx_step "fonts"

  if ! _thyx_source_has_fonts; then
    _thyx_info "no fonts/ directory with .ttf/.otf found, skipping"
    return 0
  fi

  _thyx_remove_one "${THYX_FONTS_DST}"
  _thyx_run mkdir -p -- "${THYX_FONTS_DST}"

  while IFS= read -r -d '' font; do
    _thyx_run install -m 0644 -- "${font}" "${THYX_FONTS_DST}/$(basename "${font}")"
  done < <(find -L "${fonts_src}" -type f \( -iname '*.otf' -o -iname '*.ttf' \) -print0)

  _thyx_run fc-cache -r -f >/dev/null 2>&1
  _thyx_ok "fonts installed"
}

_thyx_remove_theme_files() {
  _thyx_step "remove theme"

  _thyx_remove_one "${THYX_THEME_DST}"
  _thyx_remove_theme_staging

  _thyx_ok "theme files removed"
}

_thyx_remove_fonts() {
  local had_fonts=0

  _thyx_step "remove fonts"

  if [ -d "${THYX_FONTS_DST}" ]; then
    had_fonts=1
    _thyx_remove_one "${THYX_FONTS_DST}"
  fi

  if [ "${had_fonts}" -eq 1 ]; then
    _thyx_run fc-cache -r -f >/dev/null 2>&1
    _thyx_ok "fonts removed"
    return 0
  fi

  _thyx_ok "fonts directory not found, skipping"
}