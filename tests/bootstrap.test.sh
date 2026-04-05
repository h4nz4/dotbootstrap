#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TEST_DIR=$(mktemp -d)

cleanup() {
  rm -rf "$TEST_DIR"
}

trap cleanup EXIT INT TERM

mkdir -p "$TEST_DIR/bin" "$TEST_DIR/home" "$TEST_DIR/root"

cat >"$TEST_DIR/bin/grep" <<'EOF'
#!/usr/bin/env sh
/usr/bin/grep "$@"
EOF

cat >"$TEST_DIR/bin/curl" <<'EOF'
#!/usr/bin/env sh
case "$*" in
  *releases/latest*)
    printf '%s\n' '{"assets":[{"browser_download_url":"https://example.invalid/nvim-linux64.tar.gz"}]}'
    ;;
  *)
    printf '%s\n' 'fake-curl'
    ;;
esac
EOF

cat >"$TEST_DIR/bin/tar" <<'EOF'
#!/usr/bin/env sh
exit 0
EOF

chmod +x "$TEST_DIR/bin/grep" "$TEST_DIR/bin/curl" "$TEST_DIR/bin/tar"

PATH="$TEST_DIR/bin:$PATH"
HOME="$TEST_DIR/home"
ROOT_DIR="$ROOT_DIR"
BOOTSTRAP_ROOT_DIR="$ROOT_DIR"
BOOTSTRAP_TEST_MODE=1

export PATH HOME ROOT_DIR BOOTSTRAP_ROOT_DIR BOOTSTRAP_TEST_MODE

. "$ROOT_DIR/lib/common.sh"

ensure_line "$HOME/.zshrc" 'eval "$(starship init zsh)"'
ensure_line "$HOME/.zshrc" 'eval "$(starship init zsh)"'

count=$(/usr/bin/grep -Fc 'eval "$(starship init zsh)"' "$HOME/.zshrc")
[ "$count" -eq 1 ]

link_file "$ROOT_DIR/configs/starship.toml" "$HOME/.config/starship.toml"
[ -L "$HOME/.config/starship.toml" ]

printf '%s\n' "ok"
