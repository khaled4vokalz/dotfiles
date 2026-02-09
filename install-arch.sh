#!/usr/bin/env bash

set -o errexit
set -o pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
SKIP_PACKAGES=false
SKIP_DESKTOP=false
LINK_ARGS=()

for arg in "$@"; do
  case $arg in
    --skip-packages)
      SKIP_PACKAGES=true
      ;;
    --skip-desktop)
      SKIP_DESKTOP=true
      LINK_ARGS+=("--skip-desktop")
      ;;
    --help|-h)
      echo "Usage: ./install-arch.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --skip-packages  Skip package installation (only link configs)"
      echo "  --skip-desktop   Skip desktop environment packages and configs"
      echo "                   (hyprland, waybar, wofi, etc.)"
      echo "                   Useful if you're using Omarchy or another setup"
      echo "  --help, -h       Show this help message"
      exit 0
      ;;
  esac
done

echo "=========================================="
echo "  Arch Linux Installation Script"
echo "=========================================="
if [[ "$SKIP_PACKAGES" == true ]]; then
  echo "Mode: Skipping package installation"
fi
if [[ "$SKIP_DESKTOP" == true ]]; then
  echo "Mode: Skipping desktop environment"
fi

# Check if running on Arch
if [[ ! -f /etc/arch-release ]]; then
  echo "Error: This script is for Arch Linux only"
  exit 1
fi

# Create a temp directory for downloads and clean up on exit
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Install yay if not installed
install_yay() {
  if ! command -v yay &>/dev/null; then
    echo "Installing yay (AUR helper)..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git "$TEMP_DIR/yay"
    cd "$TEMP_DIR/yay"
    makepkg -si --noconfirm
    cd -
  else
    echo "yay already installed"
  fi
}

# Core CLI tools
install_cli_tools() {
  echo "Installing CLI tools..."
  sudo pacman -S --needed --noconfirm \
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
    yazi \
    starship \
    git-delta \
    github-cli \
    unzip \
    xclip \
    wl-clipboard

  # AUR packages
  yay -S --needed --noconfirm \
    lazydocker \
    difftastic
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
    yay -S --needed --noconfirm mise
  fi

  # Go
  sudo pacman -S --needed --noconfirm go

  # Build dependencies for pyenv
  sudo pacman -S --needed --noconfirm \
    base-devel \
    openssl \
    zlib \
    xz \
    tk \
    sqlite \
    readline \
    bzip2
}

# Terminal emulators
install_terminals() {
  echo "Installing terminal emulators..."
  sudo pacman -S --needed --noconfirm wezterm
  # Alacritty - disabled for now (using wezterm as primary)
  # sudo pacman -S --needed --noconfirm alacritty
}

# Hyprland and Wayland tools
install_hyprland() {
  echo "Installing Hyprland and Wayland tools..."
  sudo pacman -S --needed --noconfirm \
    hyprland \
    xdg-desktop-portal-hyprland \
    waybar \
    wofi \
    fuzzel \
    swaylock \
    swayidle \
    wlogout \
    dunst \
    libnotify \
    polkit-kde-agent \
    qt5-wayland \
    qt6-wayland \
    grim \
    slurp \
    wf-recorder \
    brightnessctl \
    playerctl \
    pavucontrol \
    blueman \
    networkmanager \
    nm-connection-editor \
    network-manager-applet
}

# GUI Applications
install_gui_apps() {
  echo "Installing GUI applications..."

  # Brave Browser
  yay -S --needed --noconfirm brave-bin

  # VS Code
  yay -S --needed --noconfirm visual-studio-code-bin

  # Other useful apps
  sudo pacman -S --needed --noconfirm \
    thunar \
    imv \
    mpv \
    gnome-keyring
}

# Fonts
install_fonts() {
  echo "Installing fonts..."
  sudo pacman -S --needed --noconfirm \
    ttf-jetbrains-mono-nerd \
    ttf-firacode-nerd \
    ttf-hack-nerd \
    noto-fonts \
    noto-fonts-emoji
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

# Enable services
enable_services() {
  echo "Enabling services..."
  sudo systemctl enable NetworkManager
  sudo systemctl enable bluetooth
}

# Link configuration files
link_configs() {
  echo "Linking configuration files..."
  "$DOTFILES_DIR/link-configs.sh" "${LINK_ARGS[@]}"
}

main() {
  if [[ "$SKIP_PACKAGES" == false ]]; then
    install_yay
    install_cli_tools
    install_dev_tools
    install_terminals
    if [[ "$SKIP_DESKTOP" == false ]]; then
      install_hyprland
    fi
    install_gui_apps
    install_fonts
    setup_zsh
    setup_tmux
    if [[ "$SKIP_DESKTOP" == false ]]; then
      enable_services
    fi
  fi

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
  if [[ "$SKIP_DESKTOP" == false ]]; then
    echo "  4. Log out and select Hyprland as your session"
  fi
  echo ""
}

main
