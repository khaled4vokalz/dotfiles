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
      echo "Usage: ./install-debian.sh [OPTIONS]"
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
echo "  Debian/Ubuntu Installation Script"
echo "=========================================="
if [[ "$SKIP_PACKAGES" == true ]]; then
  echo "Mode: Skipping package installation"
fi
if [[ "$SKIP_DESKTOP" == true ]]; then
  echo "Mode: Skipping desktop environment"
fi

# Check if running on Debian-based system
if [[ ! -f /etc/debian_version ]]; then
  echo "Error: This script is for Debian/Ubuntu only"
  exit 1
fi

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
  x86_64)
    ARCH_DEB="amd64"
    ARCH_RUST="x86_64-unknown-linux-gnu"
    ;;
  aarch64|arm64)
    ARCH_DEB="arm64"
    ARCH_RUST="aarch64-unknown-linux-gnu"
    ;;
  *)
    echo "Warning: Unsupported architecture: $ARCH"
    echo "Some tools may need to be installed manually"
    ARCH_DEB="amd64"
    ARCH_RUST="x86_64-unknown-linux-gnu"
    ;;
esac
echo "Architecture: $ARCH ($ARCH_DEB)"

# Create a temp directory for downloads and clean up on exit
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Update system
update_system() {
  echo "Updating system..."
  sudo apt update && sudo apt upgrade -y
}

# Install base dependencies
install_dependencies() {
  echo "Installing base dependencies..."
  sudo apt install -y \
    curl \
    wget \
    gpg \
    apt-transport-https \
    git \
    build-essential \
    software-properties-common \
    ca-certificates
}

# Core CLI tools
install_cli_tools() {
  echo "Installing CLI tools..."
  sudo apt install -y \
    zsh \
    jq \
    tree \
    htop \
    unzip \
    xclip \
    wl-clipboard

  # bat (installed as batcat on Debian/Ubuntu)
  sudo apt install -y bat
  mkdir -p ~/.local/bin
  [[ ! -L ~/.local/bin/bat ]] && ln -sf /usr/bin/batcat ~/.local/bin/bat || true

  # lsd
  sudo apt install -y lsd

  # fd (installed as fd-find on Debian/Ubuntu)
  sudo apt install -y fd-find
  [[ ! -L ~/.local/bin/fd ]] && ln -sf /usr/bin/fdfind ~/.local/bin/fd || true

  # fzf
  sudo apt install -y fzf

  # ripgrep
  sudo apt install -y ripgrep

  # zoxide
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

  # btop
  sudo apt install -y btop

  # yazi (file manager) - download prebuilt binary
  if ! command -v yazi &>/dev/null; then
    echo "Installing yazi..."
    local YAZI_VERSION
    YAZI_VERSION=$(curl -s "https://api.github.com/repos/sxyazi/yazi/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
    curl -Lo "$TEMP_DIR/yazi.zip" "https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/yazi-${ARCH_RUST}.zip"
    unzip -o "$TEMP_DIR/yazi.zip" -d "$TEMP_DIR/yazi"
    sudo install "$TEMP_DIR/yazi/yazi-${ARCH_RUST}/yazi" /usr/local/bin/
    sudo install "$TEMP_DIR/yazi/yazi-${ARCH_RUST}/ya" /usr/local/bin/
  fi

  # starship
  curl -sS https://starship.rs/install.sh | sh -s -- -y

  # GitHub CLI
  if ! command -v gh &>/dev/null; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    sudo apt update
    sudo apt install -y gh
  fi
}

# Install neovim (latest version)
install_neovim() {
  if command -v nvim &>/dev/null; then
    echo "Neovim already installed, skipping..."
    return
  fi
  echo "Installing Neovim..."
  local NVIM_VERSION="v0.11.2"
  local NVIM_ARCH
  case "$ARCH" in
    x86_64) NVIM_ARCH="x86_64" ;;
    aarch64|arm64) NVIM_ARCH="arm64" ;;
    *) NVIM_ARCH="x86_64" ;;
  esac
  curl -Lo "$TEMP_DIR/nvim.tar.gz" "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-${NVIM_ARCH}.tar.gz"
  tar -xzf "$TEMP_DIR/nvim.tar.gz" -C "$TEMP_DIR"
  sudo rm -rf /opt/nvim
  sudo mv "$TEMP_DIR/nvim-linux-${NVIM_ARCH}" /opt/nvim
  sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
}

# Install lazygit
install_lazygit() {
  if command -v lazygit &>/dev/null; then
    echo "lazygit already installed, skipping..."
    return
  fi
  echo "Installing lazygit..."
  local LAZYGIT_ARCH
  case "$ARCH" in
    x86_64) LAZYGIT_ARCH="x86_64" ;;
    aarch64|arm64) LAZYGIT_ARCH="arm64" ;;
    *) LAZYGIT_ARCH="x86_64" ;;
  esac
  local LAZYGIT_VERSION
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
  curl -Lo "$TEMP_DIR/lazygit.tar.gz" "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz"
  tar xf "$TEMP_DIR/lazygit.tar.gz" -C "$TEMP_DIR" lazygit
  sudo install "$TEMP_DIR/lazygit" -D -t /usr/local/bin/
}

# Install lazydocker
install_lazydocker() {
  if command -v lazydocker &>/dev/null; then
    echo "lazydocker already installed, skipping..."
    return
  fi
  echo "Installing lazydocker..."
  curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
}

# Install git-delta
install_delta() {
  if command -v delta &>/dev/null; then
    echo "git-delta already installed, skipping..."
    return
  fi
  echo "Installing git-delta..."
  local DELTA_VERSION="0.18.2"
  curl -Lo "$TEMP_DIR/delta.deb" "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_${ARCH_DEB}.deb"
  sudo dpkg -i "$TEMP_DIR/delta.deb"
}

# Install difftastic
install_difftastic() {
  if command -v difft &>/dev/null; then
    echo "difftastic already installed, skipping..."
    return
  fi
  echo "Installing difftastic..."
  local DIFFT_VERSION
  DIFFT_VERSION=$(curl -s "https://api.github.com/repos/Wilfred/difftastic/releases/latest" | grep -Po '"tag_name": *"\K[^"]*')
  curl -Lo "$TEMP_DIR/difft.tar.gz" "https://github.com/Wilfred/difftastic/releases/download/${DIFFT_VERSION}/difft-${ARCH_RUST}.tar.gz"
  tar -xzf "$TEMP_DIR/difft.tar.gz" -C "$TEMP_DIR"
  sudo install "$TEMP_DIR/difft" /usr/local/bin/
}

# Development tools
install_dev_tools() {
  echo "Installing development tools..."

  # Rust (needed for some tools)
  if ! command -v rustc &>/dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
  else
    echo "Rust already installed"
  fi

  # Node Version Manager (NVM)
  if [[ ! -d "$HOME/.config/nvm" ]]; then
    echo "Installing NVM..."
    export NVM_DIR="$HOME/.config/nvm"
    mkdir -p "$NVM_DIR"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  else
    echo "NVM already installed"
  fi

  # mise (modern alternative to pyenv/nvm/rbenv)
  if command -v mise &>/dev/null; then
    echo "mise already installed"
  else
    echo "Installing mise..."
    curl https://mise.run | sh
    # Add mise to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
  fi

  # Install Python build dependencies (for mise/pyenv to compile Python)
  sudo apt install -y \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev

  # Go
  if ! command -v go &>/dev/null; then
    echo "Installing Go..."
    local GO_VERSION="1.22.0"
    local GO_ARCH
    case "$ARCH" in
      x86_64) GO_ARCH="amd64" ;;
      aarch64|arm64) GO_ARCH="arm64" ;;
      *) GO_ARCH="amd64" ;;
    esac
    curl -Lo go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf go.tar.gz
    rm -f go.tar.gz
  fi

  # tmux
  sudo apt install -y tmux
}

# Terminal emulators
install_terminals() {
  echo "Installing terminal emulators..."

  # Wezterm
  curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /etc/apt/keyrings/wezterm-fury.gpg
  echo 'deb [signed-by=/etc/apt/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
  sudo apt update
  sudo apt install -y wezterm

  # Alacritty - disabled for now (PPA doesn't support all Ubuntu versions)
  # sudo add-apt-repository ppa:aslatter/ppa -y 2>/dev/null || true
  # sudo apt update
  # sudo apt install -y alacritty
}

# Hyprland and Wayland tools
install_hyprland() {
  echo "Installing Hyprland and Wayland tools..."
  echo "Note: Hyprland on Ubuntu/Debian may require additional repositories or building from source"

  # Install available wayland tools
  sudo apt install -y \
    waybar \
    wofi \
    swaylock \
    swayidle \
    dunst \
    libnotify-bin \
    grim \
    slurp \
    wf-recorder \
    brightnessctl \
    playerctl \
    pavucontrol \
    blueman \
    network-manager \
    network-manager-gnome

  # fuzzel and wlogout may need to be built from source
  if ! command -v fuzzel &>/dev/null; then
    echo "Note: fuzzel may not be available in default repos. Consider building from source."
  fi

  # Hyprland - check if available or provide instructions
  if apt-cache show hyprland &>/dev/null; then
    sudo apt install -y hyprland xdg-desktop-portal-hyprland
  else
    echo ""
    echo "Hyprland is not available in default Ubuntu/Debian repos."
    echo "For Ubuntu 24.04+, you can try:"
    echo "  sudo add-apt-repository ppa:hyprwm/hyprland"
    echo "  sudo apt update && sudo apt install hyprland"
    echo ""
    echo "Or build from source: https://wiki.hyprland.org/Getting-Started/Installation/"
    echo ""
  fi
}

# GUI Applications
install_gui_apps() {
  echo "Installing GUI applications..."

  # Brave Browser
  curl -fsS https://dl.brave.com/install.sh | sh

  # VS Code
  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --yes --dearmor -o /usr/share/keyrings/packages.microsoft.gpg
  echo "deb [arch=${ARCH_DEB} signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
  sudo apt update
  sudo apt install -y code

  # Other useful apps
  sudo apt install -y \
    thunar \
    imv \
    mpv \
    gnome-keyring
}

# Fonts
install_fonts() {
  echo "Installing fonts..."
  sudo apt install -y \
    fonts-jetbrains-mono \
    fonts-firacode \
    fonts-hack

  # Install Nerd Fonts manually
  local FONT_DIR="$HOME/.local/share/fonts"
  mkdir -p "$FONT_DIR"

  # JetBrains Mono Nerd Font
  if [[ ! -f "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]]; then
    echo "Installing JetBrains Mono Nerd Font..."
    curl -Lo /tmp/JetBrainsMono.zip "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    unzip -o /tmp/JetBrainsMono.zip -d "$FONT_DIR"
    rm -f /tmp/JetBrainsMono.zip
    fc-cache -fv
  fi
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
  sudo systemctl enable NetworkManager 2>/dev/null || true
  sudo systemctl enable bluetooth 2>/dev/null || true
}

# Link configuration files
link_configs() {
  echo "Linking configuration files..."
  "$DOTFILES_DIR/link-configs.sh" "${LINK_ARGS[@]}"
}

main() {
  if [[ "$SKIP_PACKAGES" == false ]]; then
    update_system
    install_dependencies
    install_dev_tools  # Install Rust first, needed for some tools
    install_cli_tools
    install_neovim
    install_lazygit
    install_lazydocker
    install_delta
    install_difftastic
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
