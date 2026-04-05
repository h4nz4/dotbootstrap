#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if [ "${BOOTSTRAP_TEST_MODE:-0}" = "1" ]; then
  ROOT_DIR=${BOOTSTRAP_ROOT_DIR:-$ROOT_DIR}
fi

. "$ROOT_DIR/lib/common.sh"
. "$ROOT_DIR/lib/detect.sh"

main() {
  detect_os

  printf '\n'
  printf '  dotbootstrap · %s %s\n' "$BOOTSTRAP_OS_NAME" "${BOOTSTRAP_OS_VERSION:-}"
  printf '\n'

  case "$BOOTSTRAP_OS_ID" in
    debian|ubuntu)
      . "$ROOT_DIR/lib/linux.sh"
      linux_bootstrap
      ;;
    arch)
      . "$ROOT_DIR/lib/linux.sh"
      linux_bootstrap
      ;;
    macos)
      . "$ROOT_DIR/lib/macos.sh"
      macos_bootstrap
      ;;
    *)
      die "Unsupported operating system: $BOOTSTRAP_OS_ID"
      ;;
  esac

  printf '\n  Done.\n\n'
}

main "$@"
