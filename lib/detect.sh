#!/usr/bin/env sh

detect_os() {
  if [ "$(uname -s)" = "Darwin" ]; then
    BOOTSTRAP_OS_ID=macos
    BOOTSTRAP_OS_NAME=macOS
    BOOTSTRAP_OS_VERSION=$(sw_vers -productVersion 2>/dev/null || true)
    return
  fi

  if [ -r /etc/os-release ]; then
    . /etc/os-release
    BOOTSTRAP_OS_ID=${ID:-unknown}
    BOOTSTRAP_OS_NAME=${NAME:-unknown}
    BOOTSTRAP_OS_VERSION=${VERSION_ID:-}
    return
  fi

  BOOTSTRAP_OS_ID=unknown
  BOOTSTRAP_OS_NAME=unknown
  BOOTSTRAP_OS_VERSION=
}
