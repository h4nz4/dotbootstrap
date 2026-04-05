#!/usr/bin/env sh

log() {
  printf '%s\n' "[bootstrap] $*"
}

warn() {
  printf '%s\n' "[bootstrap] warning: $*" >&2
}

die() {
  printf '%s\n' "[bootstrap] error: $*" >&2
  exit 1
}

have() {
  command -v "$1" >/dev/null 2>&1
}

_bootstrap_is_tty() {
  [ -t 1 ]
}

_bootstrap_clear_line() {
  printf '\033[2K' 2>/dev/null || printf '\r'
}

run_step() {
  step_msg=$1
  shift
  step_tmp=$(mktemp) || die "mktemp failed"

  if _bootstrap_is_tty; then
    (
      step_i=0
      while :; do
        step_i=$((step_i + 1))
        case $((step_i % 4)) in
          1) step_c='|' ;;
          2) step_c='/' ;;
          3) step_c='-' ;;
          0) step_c='.' ;;
        esac
        printf '\r  %s %s' "$step_c" "$step_msg"
        sleep 0.15 >/dev/null 2>&1 || sleep 1
      done
    ) &
    step_sp=$!
    if "$@" >"$step_tmp" 2>&1; then
      kill "$step_sp" 2>/dev/null
      wait "$step_sp" 2>/dev/null
      _bootstrap_clear_line
      printf '\r  ✓ %s\n' "$step_msg"
      rm -f "$step_tmp"
    else
      kill "$step_sp" 2>/dev/null
      wait "$step_sp" 2>/dev/null
      _bootstrap_clear_line
      cat "$step_tmp" >&2
      rm -f "$step_tmp"
      die "Failed: $step_msg"
    fi
  else
    printf '%s\n' "[bootstrap] $step_msg …"
    if "$@" >"$step_tmp" 2>&1; then
      printf '%s\n' "[bootstrap] done: $step_msg"
      rm -f "$step_tmp"
    else
      cat "$step_tmp" >&2
      rm -f "$step_tmp"
      die "Failed: $step_msg"
    fi
  fi
}

run_step_live() {
  step_msg=$1
  shift
  printf '%s\n' "  → $step_msg"
  "$@" || die "Failed: $step_msg"
}

run() {
  "$@"
}

run_as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

ensure_line() {
  file=$1
  line=$2

  mkdir -p "$(dirname "$file")"
  touch "$file"

  if ! grep -Fxq "$line" "$file"; then
    printf '%s\n' "$line" >>"$file"
  fi
}

backup_file() {
  file=$1

  if [ -e "$file" ] && [ ! -e "${file}.bootstrap.bak" ]; then
    mv "$file" "${file}.bootstrap.bak"
  fi
}

link_file() {
  src=$1
  dst=$2

  mkdir -p "$(dirname "$dst")"

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    backup_file "$dst"
  fi

  ln -s "$src" "$dst"
}
