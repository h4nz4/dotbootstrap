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

# install.sh uses set -e; kill/wait often return non-zero (dead PID) and must not abort the script.
_bootstrap_stop_spinner() {
  step_sp=$1
  [ -n "$step_sp" ] || return 0
  kill "$step_sp" 2>/dev/null || true
  wait "$step_sp" 2>/dev/null || true
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
    trap "_bootstrap_stop_spinner $step_sp; _bootstrap_clear_line; printf '\n' >&2; exit 130" INT
    trap "_bootstrap_stop_spinner $step_sp; _bootstrap_clear_line; printf '\n' >&2; exit 143" TERM
    # Subshell: install.sh uses set -e, so failures must not abort before we print logs.
    ( "$@" ) >"$step_tmp" 2>&1
    step_ec=$?
    _bootstrap_stop_spinner "$step_sp"
    trap - INT TERM
    if [ "$step_ec" -eq 0 ]; then
      _bootstrap_clear_line
      printf '\r  ✓ %s\n' "$step_msg"
      rm -f "$step_tmp"
    else
      _bootstrap_clear_line
      printf '\r  ✗ %s\n' "$step_msg" >&2
      cat "$step_tmp" >&2
      rm -f "$step_tmp"
      die "Failed: $step_msg"
    fi
  else
    printf '%s\n' "[bootstrap] $step_msg …"
    ( "$@" ) >"$step_tmp" 2>&1
    step_ec=$?
    if [ "$step_ec" -eq 0 ]; then
      printf '%s\n' "[bootstrap] done: $step_msg"
      rm -f "$step_tmp"
    else
      printf '[bootstrap] error: %s failed (exit %s). Output:\n' "$step_msg" "$step_ec" >&2
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
  set +e
  "$@"
  step_ec=$?
  set -e
  if [ "$step_ec" -ne 0 ]; then
    die "Failed: $step_msg (exit $step_ec)"
  fi
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
