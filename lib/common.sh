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

run() {
  log "$*"
  "$@"
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
