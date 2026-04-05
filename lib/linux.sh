#!/usr/bin/env sh

linux_bootstrap() {
  run_step "Installing packages" linux_install_base_packages
  run_step_live "Configuring zsh" zsh_bootstrap
  run_step "Installing Starship" starship_bootstrap
  run_step "Installing Neovim" nvim_bootstrap
  run_step "Installing uv" uv_bootstrap
  run_step "Installing nvm" nvm_bootstrap
  run_step "Installing Docker" docker_bootstrap_linux
  run_step "Linking configuration files" config_bootstrap
}

linux_install_base_packages() {
  case "$BOOTSTRAP_OS_ID" in
    debian|ubuntu)
      run_as_root env DEBIAN_FRONTEND=noninteractive apt-get -qq update
      run_as_root env DEBIAN_FRONTEND=noninteractive apt-get -qq install -y \
        bash build-essential git wget curl zsh btop ca-certificates gnupg ripgrep fd-find tmux xclip unzip
      ;;
    arch)
      run_as_root pacman -Sy --noconfirm --noprogressbar --needed \
        bash base-devel git wget curl zsh btop ca-certificates gnupg ripgrep fd tmux xclip unzip
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
  case $(uname -m) in
    x86_64 | amd64)
      nvim_tar_name=nvim-linux-x86_64.tar.gz
      nvim_unpack_dir=nvim-linux-x86_64
      ;;
    aarch64 | arm64)
      nvim_tar_name=nvim-linux-arm64.tar.gz
      nvim_unpack_dir=nvim-linux-arm64
      ;;
    *)
      die "Unsupported architecture for Neovim: $(uname -m)"
      ;;
  esac

  tmpdir=$(mktemp -d)
  archive="$tmpdir/nvim.tar.gz"
  asset_url=$(
    curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest |
      grep "browser_download_url" |
      grep -F "$nvim_tar_name" |
      head -n 1 |
      sed 's/.*"browser_download_url": "//;s/".*//'
  )

  if [ -z "$asset_url" ]; then
    rm -rf "$tmpdir"
    die "Could not determine latest nvim release for Linux"
  fi

  run curl -fsSL "$asset_url" -o "$archive"
  run tar -C "$tmpdir" -xzf "$archive"
  run_as_root mkdir -p /opt/nvim
  run_as_root rm -rf /opt/nvim/*
  run_as_root cp -R "$tmpdir/$nvim_unpack_dir"/* /opt/nvim/
  run_as_root ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
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
    run bash -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash"
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
