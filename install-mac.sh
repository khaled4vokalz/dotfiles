#!/usr/bin/env bash

set -o errexit
set -o pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "  macOS Installation Script"
echo "=========================================="

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
  echo "Error: This script is for macOS only"
  exit 1
fi

# Create a temp directory for downloads and clean up on exit
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Install Homebrew if not installed
install_homebrew() {
  if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to PATH for Apple Silicon
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  else
    echo "Homebrew already installed"
  fi
}

# Core CLI tools
install_cli_tools() {
  echo "Installing CLI tools..."
  brew install \
    git \
    curl \
    wget \
    zsh \
    bat \
    lsd \
    fd \
    fzf \
    ripgrep \
    zoxide \
    jq \
    tree \
    htop \
    btop \
    neovim \
    tmux \
    lazygit \
    lazydocker \
    yazi \
    starship \
    git-delta \
    difftastic \
    gh
}

# Development tools
install_dev_tools() {
  echo "Installing development tools..."

  # Rust
  if ! command -v rustc &>/dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
  else
    echo "Rust already installed"
  fi

  # mise (runtime manager for Python, Node, Go, etc.)
  if command -v mise &>/dev/null; then
    echo "mise already installed"
  else
    echo "Installing mise..."
    brew install mise
  fi

  # Go
  brew install go
}

# Terminal emulators
install_terminals() {
  echo "Installing terminal emulators..."
  brew install --cask wezterm
  # Alacritty - disabled for now (using wezterm as primary)
  # brew install --cask alacritty
}

# GUI Applications
install_gui_apps() {
  echo "Installing GUI applications..."
  brew install --cask brave-browser
  brew install --cask visual-studio-code
  brew install --cask aerospace  # macOS tiling window manager
}

# Fonts
install_fonts() {
  echo "Installing fonts..."
  brew tap homebrew/cask-fonts 2>/dev/null || true
  brew install --cask font-jetbrains-mono-nerd-font
  brew install --cask font-fira-code-nerd-font
  brew install --cask font-hack-nerd-font
}

# Zsh setup
setup_zsh() {
  echo "Setting up Zsh..."

  # Set zsh as default shell
  if [[ "$SHELL" != *"zsh"* ]]; then
    chsh -s "$(which zsh)"
  fi

  # Install Oh-My-Zsh
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Installing Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  else
    echo "Oh-My-Zsh already installed"
  fi

  # Install zsh plugins
  local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  fi

  if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-vi-mode" ]]; then
    git clone https://github.com/jeffreytse/zsh-vi-mode "$ZSH_CUSTOM/plugins/zsh-vi-mode"
  fi

  if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]]; then
    git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
  fi
}

# Tmux setup
setup_tmux() {
  echo "Setting up Tmux..."
  if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  fi
}

# Link configuration files
link_configs() {
  echo "Linking configuration files..."
  "$DOTFILES_DIR/link-configs.sh"
}

main() {
  install_homebrew
  install_cli_tools
  install_dev_tools
  install_terminals
  install_gui_apps
  install_fonts
  setup_zsh
  setup_tmux
  link_configs

  echo ""
  echo "=========================================="
  echo "  Installation complete!"
  echo "=========================================="
  echo ""
  echo "Next steps:"
  echo "  1. Restart your terminal or run: source ~/.zshrc"
  echo "  2. Install tmux plugins: Press prefix + I in tmux"
  echo "  3. Open neovim to install plugins: nvim"
  echo ""
}

main "$@"
