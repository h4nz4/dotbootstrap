#!/usr/bin/env sh

set -eu

BOOTSTRAP_REPO="${BOOTSTRAP_REPO:-h4nz4/dotbootstrap}"
BOOTSTRAP_REF="${BOOTSTRAP_REF:-main}"
BOOTSTRAP_HOME="${BOOTSTRAP_HOME:-$HOME/.local/share/dotbootstrap}"

[ -n "${HOME:-}" ] || {
  printf '%s\n' 'bootstrap: HOME is not set' >&2
  exit 1
}

url="https://github.com/${BOOTSTRAP_REPO}/archive/refs/heads/${BOOTSTRAP_REF}.tar.gz"

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT INT TERM

if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$url" -o "$tmp"
elif command -v wget >/dev/null 2>&1; then
  wget -q "$url" -O "$tmp"
else
  printf '%s\n' 'bootstrap: need curl or wget' >&2
  exit 1
fi

rm -rf "$BOOTSTRAP_HOME"
mkdir -p "$BOOTSTRAP_HOME"
tar -xzf "$tmp" --strip-components=1 -C "$BOOTSTRAP_HOME"

cd "$BOOTSTRAP_HOME"
exec sh install.sh "$@"
