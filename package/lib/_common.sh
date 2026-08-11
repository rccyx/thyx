#!/usr/bin/env bash

if [ -t 1 ]; then
  THYX_RED='\033[0;31m'
  THYX_GREEN='\033[0;32m'
  THYX_YELLOW='\033[0;33m'
  THYX_BLUE='\033[0;34m'
  THYX_MAGENTA='\033[0;35m'
  THYX_CYAN='\033[0;36m'
  THYX_BOLD='\033[1m'
  THYX_DIM='\033[2m'
  THYX_NC='\033[0m'
else
  THYX_RED=''
  THYX_GREEN=''
  THYX_YELLOW=''
  THYX_BLUE=''
  THYX_MAGENTA=''
  THYX_CYAN=''
  THYX_BOLD=''
  THYX_DIM=''
  THYX_NC=''
fi

_thyx_run() {
  "${THYX_SUDO[@]}" "$@"
}

_thyx_log() {
  printf '%b\n' "$*"
}

_thyx_die() {
  printf '%b\n' "${THYX_RED}${THYX_BOLD}error:${THYX_NC} $*" >&2
  exit 1
}

_thyx_ok() {
  printf '%b\n\n' "${THYX_GREEN}${THYX_BOLD}ok:${THYX_NC} $*"
}

_thyx_warn() {
  printf '%b\n\n' "${THYX_YELLOW}${THYX_BOLD}warn:${THYX_NC} $*"
}

_thyx_info() {
  printf '%b\n\n' "${THYX_BLUE}${THYX_BOLD}info:${THYX_NC} $*"
}

_thyx_step() {
  printf '%b\n' "${THYX_MAGENTA}${THYX_BOLD}==>${THYX_NC} $*"
}

_thyx_hr() {
  printf '%b\n' "${THYX_CYAN}${THYX_DIM}------------------------------------------------------------${THYX_NC}"
}

_thyx_is_noninteractive() {
  [ ! -t 0 ]
}

_thyx_require_home() {
  [ -n "${HOME:-}" ] || _thyx_die "HOME is not set"
  [ "${HOME#/}" != "${HOME}" ] || _thyx_die "HOME must be absolute: ${HOME}"
  [ "${HOME}" != "/" ] || _thyx_die "HOME cannot be /"
}

_thyx_parse_args() {
  while [ "${#}" -gt 0 ]; do
    case "$1" in
      --yes|-y)
        THYX_AUTO_YES=1
        ;;
      *)
        _thyx_die "unknown arg: $1 (only --yes/-y supported)"
        ;;
    esac
    shift
  done
}

_thyx_setup_log() {
  _thyx_require_home
  mkdir -p -- "${THYX_CACHE_DIR}"
  THYX_LOG_FILE="${THYX_CACHE_DIR}/${THYX_LOG_PREFIX// /-}-${THYX_TIMESTAMP}.log"
  exec > >(tee -a "${THYX_LOG_FILE}") 2>&1
  _thyx_info "log: ${THYX_LOG_FILE}"
}

_thyx_on_err() {
  local code="$?"
  local line="${BASH_LINENO[0]:-?}"
  local cmd="${BASH_COMMAND:-?}"

  printf '\n'
  _thyx_warn "failed with exit ${code}"
  _thyx_warn "line: ${line}"
  _thyx_warn "cmd: ${cmd}"
  _thyx_warn "log: ${THYX_LOG_FILE}"
  exit "${code}"
}

_thyx_confirm() {
  local prompt="${1:?}"

  if _thyx_is_noninteractive; then
    [ "${THYX_AUTO_YES}" -eq 1 ] || _thyx_die "noninteractive stdin: pass --yes"
    _thyx_ok "noninteractive: skipping confirmation (--yes)"
    return 0
  fi

  if [ "${THYX_AUTO_YES}" -eq 1 ]; then
    _thyx_ok "auto mode: skipping confirmation (--yes/-y)"
    return 0
  fi

  printf '\n'
  printf '%b' "${THYX_CYAN}${prompt}${THYX_NC} "

  local ans
  IFS= read -r ans || true
  [ "${ans:-}" = "y" ] || _thyx_die "aborted"
}

_thyx_sudo_warmup() {
  if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    THYX_SUDO=()
    _thyx_ok "running as root"
    return 0
  fi

  THYX_SUDO=(sudo)

  _thyx_step "sudo"
  _thyx_info "sudo is required for /usr and /etc changes"

  if sudo -n true >/dev/null 2>&1; then
    _thyx_ok "sudo: non-interactive ok"
    return 0
  fi

  if _thyx_is_noninteractive; then
    _thyx_die "noninteractive stdin and not root: run as root, or provide passwordless sudo"
  fi

  sudo -v || _thyx_die "sudo auth failed"
  _thyx_ok "sudo ok"
}

_thyx_require_absolute() {
  local path="${1:-}"

  [ -n "${path}" ] || _thyx_die "refusing to remove empty path"
  [ "${path#/}" != "${path}" ] || _thyx_die "refusing relative path: ${path}"
  [ "${path}" != "/" ] || _thyx_die "refusing to remove /"
  [ "${path}" != "${HOME:-}" ] || _thyx_die "refusing to remove HOME: ${path}"
}

_thyx_remove_one() {
  local path="${1:-}"

  _thyx_require_absolute "${path}"
  if [ ! -e "${path}" ] && [ ! -L "${path}" ]; then
    return 0
  fi

  _thyx_run rm -rf -- "${path}"
}
