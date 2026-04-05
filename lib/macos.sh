#!/usr/bin/env sh

macos_bootstrap() {
  macos_install_homebrew
  macos_install_packages
  zsh_bootstrap_macos
  starship_bootstrap_macos
  nvim_bootstrap_macos
  uv_bootstrap_macos
  nvm_bootstrap_macos
  docker_bootstrap_macos
  config_bootstrap_macos
}

macos_install_homebrew() {
  if ! have brew; then
    run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi
}

macos_install_packages() {
  run brew install git wget curl zsh btop ripgrep fd tmux xclip unzip ca-certificates starship neovim uv nvm
}

zsh_bootstrap_macos() {
  chsh -s "$(command -v zsh)" "${USER:-$(id -un)}" || warn "Could not set default shell automatically"
}

starship_bootstrap_macos() {
  ensure_line "$HOME/.zshrc" 'eval "$(starship init zsh)"'
}

nvim_bootstrap_macos() {
  :
}

uv_bootstrap_macos() {
  ensure_line "$HOME/.zshrc" 'export PATH="$HOME/.local/bin:$PATH"'
}

nvm_bootstrap_macos() {
  ensure_line "$HOME/.zshrc" 'export NVM_DIR="$HOME/.nvm"'
  ensure_line "$HOME/.zshrc" '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"'
  ensure_line "$HOME/.zshrc" '[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"'
}

docker_bootstrap_macos() {
  :
}

config_bootstrap_macos() {
  mkdir -p "$HOME/.config"
  link_file "$ROOT_DIR/configs/starship.toml" "$HOME/.config/starship.toml"
  link_file "$ROOT_DIR/configs/nvim/init.lua" "$HOME/.config/nvim/init.lua"
}
