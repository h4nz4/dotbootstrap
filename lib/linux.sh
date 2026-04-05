#!/usr/bin/env sh

linux_bootstrap() {
  linux_install_base_packages
  zsh_bootstrap
  starship_bootstrap
  nvim_bootstrap
  uv_bootstrap
  nvm_bootstrap
  docker_bootstrap_linux
  config_bootstrap
}

linux_install_base_packages() {
  case "$BOOTSTRAP_OS_ID" in
    debian|ubuntu)
      run sudo apt-get update
      run sudo apt-get install -y build-essential git wget curl zsh btop ca-certificates gnupg ripgrep fd-find tmux xclip unzip
      ;;
    arch)
      run sudo pacman -Sy --noconfirm --needed base-devel git wget curl zsh btop ca-certificates gnupg ripgrep fd tmux xclip unzip
      ;;
  esac
}

zsh_bootstrap() {
  if ! have zsh; then
    die "zsh is not installed"
  fi

  if [ "${SHELL:-}" != "$(command -v zsh)" ]; then
    chsh -s "$(command -v zsh)" "${USER:-$(id -un)}" || warn "Could not set default shell automatically"
  fi
}

starship_bootstrap() {
  if ! have starship; then
    run sh -c "curl -fsSL https://starship.rs/install.sh | sh -s -- -y"
  fi
  ensure_line "$HOME/.zshrc" 'eval "$(starship init zsh)"'
}

nvim_bootstrap() {
  if ! have nvim; then
    nvim_install_linux_latest
  fi
}

nvim_install_linux_latest() {
  tmpdir=$(mktemp -d)
  archive="$tmpdir/nvim.tar.gz"
  asset_url=$(curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest | sed -n 's/.*"browser_download_url": *"\([^"]*linux64.tar.gz\)".*/\1/p' | head -n 1)

  if [ -z "$asset_url" ]; then
    rm -rf "$tmpdir"
    die "Could not determine latest nvim release for Linux"
  fi

  run curl -fsSL "$asset_url" -o "$archive"
  run tar -C "$tmpdir" -xzf "$archive"
  sudo mkdir -p /opt/nvim
  sudo rm -rf /opt/nvim/*
  sudo cp -R "$tmpdir"/nvim-linux64/* /opt/nvim/
  sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
  rm -rf "$tmpdir"
}

uv_bootstrap() {
  if ! have uv; then
    run sh -c "curl -LsSf https://astral.sh/uv/install.sh | sh"
  fi
  ensure_line "$HOME/.zshrc" 'export PATH="$HOME/.local/bin:$PATH"'
}

nvm_bootstrap() {
  if [ ! -d "$HOME/.nvm" ]; then
    run sh -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | sh"
  fi
  ensure_line "$HOME/.zshrc" 'export NVM_DIR="$HOME/.nvm"'
  ensure_line "$HOME/.zshrc" '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"'
  ensure_line "$HOME/.zshrc" '[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"'
}

docker_bootstrap_linux() {
  if have docker; then
    return
  fi

  run sh -c "curl -fsSL https://get.docker.com/ | sh"
}

config_bootstrap() {
  config_dir="$HOME/.config"
  mkdir -p "$config_dir"

  link_file "$ROOT_DIR/configs/starship.toml" "$HOME/.config/starship.toml"
  link_file "$ROOT_DIR/configs/nvim/init.lua" "$HOME/.config/nvim/init.lua"
}
