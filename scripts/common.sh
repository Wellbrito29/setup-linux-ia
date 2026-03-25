#!/usr/bin/env bash

if [[ -t 1 ]]; then
  C_RESET='\033[0m'
  C_BOLD='\033[1m'
  C_DIM='\033[2m'
  C_RED='\033[31m'
  C_GREEN='\033[32m'
  C_YELLOW='\033[33m'
  C_BLUE='\033[34m'
  C_MAGENTA='\033[35m'
  C_CYAN='\033[36m'
else
  C_RESET=''
  C_BOLD=''
  C_DIM=''
  C_RED=''
  C_GREEN=''
  C_YELLOW=''
  C_BLUE=''
  C_MAGENTA=''
  C_CYAN=''
fi

log() {
  printf '\n%b[%s]%b %s\n' "$C_CYAN" "$(date '+%H:%M:%S')" "$C_RESET" "$*"
}

ok() {
  printf '%b[ok]%b %s\n' "$C_GREEN" "$C_RESET" "$*"
}

warn() {
  printf '%b[warn]%b %s\n' "$C_YELLOW" "$C_RESET" "$*"
}

skip() {
  printf '%b[skip]%b %s\n' "$C_BLUE" "$C_RESET" "$*"
}

err() {
  printf '%b[error]%b %s\n' "$C_RED" "$C_RESET" "$*" >&2
}

title() {
  printf '\n%b%s%b\n' "$C_BOLD$C_MAGENTA" "$*" "$C_RESET"
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

append_if_missing() {
  local file="$1"
  local line="$2"
  grep -Fqx "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

run_step() {
  local label="$1"
  local script="$2"
  title "==> $label"
  "$script"
}

pause() {
  read -r -p 'Pressione Enter para continuar...' _ </dev/tty
}

status_line() {
  local label="$1"
  local state="$2"
  local extra="${3:-}"
  local tag
  case "$state" in
    ok) tag="${C_GREEN}[OK]${C_RESET}" ;;
    pending) tag="${C_YELLOW}[PENDENTE]${C_RESET}" ;;
    partial) tag="${C_BLUE}[PARCIAL]${C_RESET}" ;;
    *) tag="[?]" ;;
  esac
  printf ' %-28s %b' "$label" "$tag"
  if [[ -n "$extra" ]]; then
    printf ' %b%s%b' "$C_DIM" "$extra" "$C_RESET"
  fi
  printf '\n'
}
