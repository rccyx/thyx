#!/usr/bin/env bash

_thyx_source_has_fonts() {
  local fonts_src="${THYX_REPO_DIR}/fonts"

  [ -d "${fonts_src}" ] || return 1
  find -L "${fonts_src}" -type f \( -iname '*.otf' -o -iname '*.ttf' \) -print -quit | grep -q .
}

_thyx_install_theme_atomic() {
  local parent
  local stage
  local backup

  _thyx_step "theme"
  _thyx_validate_repo_tree "${THYX_REPO_DIR}"

  parent="$(dirname "${THYX_THEME_DST}")"
  stage="${parent}/.${THYX_THEME_ID}.stage.${THYX_TIMESTAMP}"
  backup="${parent}/.${THYX_THEME_ID}.bak.${THYX_TIMESTAMP}"

  _thyx_info "staging to: ${stage}"
  _thyx_remove_one "${stage}"
  _thyx_run mkdir -p -- "${stage}"

  _thyx_run rsync -a --delete \
    --exclude '.git/' \
    --exclude '.github/' \
    --exclude '.agents/' \
    --exclude '.codex/' \
    --exclude 'justfile' \
    --exclude '.qmllint.ini' \
    "${THYX_REPO_DIR}/" "${stage}/"

  _thyx_validate_repo_tree "${stage}"

  _thyx_info "activating: ${THYX_THEME_DST}"
  _thyx_remove_one "${backup}"

  if [ -d "${THYX_THEME_DST}" ]; then
    _thyx_run mv -- "${THYX_THEME_DST}" "${backup}"
  fi

  if ! _thyx_run mv -- "${stage}" "${THYX_THEME_DST}"; then
    _thyx_restore_theme_backup "${backup}"
    return 1
  fi

  if ! ( _thyx_validate_repo_tree "${THYX_THEME_DST}" ); then
    _thyx_remove_one "${THYX_THEME_DST}"
    _thyx_restore_theme_backup "${backup}"
    return 1
  fi

  _thyx_remove_one "${backup}"
  _thyx_ok "theme installed"
}

_thyx_restore_theme_backup() {
  local backup="${1:?}"

  if [ ! -e "${backup}" ] && [ ! -L "${backup}" ]; then
    return 0
  fi

  _thyx_warn "restoring previous theme"
  _thyx_remove_one "${THYX_THEME_DST}"
  _thyx_run mv -- "${backup}" "${THYX_THEME_DST}"
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

  _thyx_run fc-cache -f >/dev/null 2>&1
  _thyx_ok "fonts installed"
}

_thyx_remove_theme_files() {
  local path

  _thyx_step "remove theme"
  _thyx_remove_one "${THYX_THEME_DST}"

  shopt -s nullglob
  for path in "/usr/share/sddm/themes/.${THYX_THEME_ID}.stage."* "/usr/share/sddm/themes/.${THYX_THEME_ID}.bak."*; do
    _thyx_remove_one "${path}"
  done
  shopt -u nullglob

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
    _thyx_run fc-cache -f >/dev/null 2>&1
    _thyx_ok "fonts removed"
    return 0
  fi

  _thyx_ok "fonts directory not found, skipping"
}
