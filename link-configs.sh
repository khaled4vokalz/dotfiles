#!/usr/bin/env bash

set -o errexit
set -o pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Parse arguments
SKIP_DESKTOP=false
for arg in "$@"; do
  case $arg in
    --skip-desktop)
      SKIP_DESKTOP=true
      ;;
    --help|-h)
      echo "Usage: ./link-configs.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --skip-desktop  Skip linking desktop environment configs"
      echo "                  (waybar, wofi, fuzzel, wlogout, swaylock, hyprland)"
      echo "                  Useful if you're using Omarchy or another pre-configured setup"
      echo "  --help, -h      Show this help message"
      exit 0
      ;;
  esac
done

echo "=========================================="
echo "  Linking Configuration Files"
echo "=========================================="
echo "Dotfiles directory: $DOTFILES_DIR"
if [[ "$SKIP_DESKTOP" == true ]]; then
  echo "Mode: Skipping desktop environment configs"
fi
echo ""

# Create a backup of existing config if it exists and is not a symlink
backup_if_exists() {
  local target="$1"
  if [[ -e "$target" && ! -L "$target" ]]; then
    mkdir -p "$BACKUP_DIR"
    echo "  Backing up existing: $target -> $BACKUP_DIR/"
    mv "$target" "$BACKUP_DIR/"
  elif [[ -L "$target" ]]; then
    rm -f "$target"
  fi
}

# Create symlink
create_link() {
  local source="$1"
  local target="$2"

  if [[ ! -e "$source" ]]; then
    echo "  Skipping (source not found): $source"
    return
  fi

  backup_if_exists "$target"

  # Create parent directory if needed
  mkdir -p "$(dirname "$target")"

  ln -sf "$source" "$target"
  echo "  Linked: $target -> $source"
}

# Detect OS
detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux) echo "linux" ;;
    *) echo "unknown" ;;
  esac
}

OS=$(detect_os)
echo "Detected OS: $OS"
echo ""

# ============================================
# Common configurations (all platforms)
# ============================================
echo "Linking common configurations..."

# Shell configs
create_link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
create_link "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
create_link "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"

# Starship prompt
create_link "$DOTFILES_DIR/starship.toml" "$CONFIG_DIR/starship.toml"

# Neovim
create_link "$DOTFILES_DIR/nvim" "$CONFIG_DIR/nvim"

# Wezterm
create_link "$DOTFILES_DIR/wezterm" "$CONFIG_DIR/wezterm"

# Alacritty
create_link "$DOTFILES_DIR/alacritty" "$CONFIG_DIR/alacritty"

# Tmux
create_link "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
create_link "$DOTFILES_DIR/tmux/tmux.reset.conf" "$HOME/.tmux.reset.conf"

# Lazygit
create_link "$DOTFILES_DIR/lazygit" "$CONFIG_DIR/lazygit"

# Yazi
create_link "$DOTFILES_DIR/yazi" "$CONFIG_DIR/yazi"

# Git delta themes
create_link "$DOTFILES_DIR/delta" "$CONFIG_DIR/delta"

# Wallpapers
create_link "$DOTFILES_DIR/wallpapers" "$CONFIG_DIR/wallpapers"

# ============================================
# macOS-specific configurations
# ============================================
if [[ "$OS" == "macos" ]]; then
  echo ""
  echo "Linking macOS-specific configurations..."

  # Aerospace (macOS tiling window manager)
  if [[ -d "$DOTFILES_DIR/aerospace" ]]; then
    create_link "$DOTFILES_DIR/aerospace" "$CONFIG_DIR/aerospace"
  fi
fi

# ============================================
# Linux-specific configurations
# ============================================
if [[ "$OS" == "linux" ]]; then
  echo ""
  echo "Linking Linux-specific configurations..."

  # Always link hypr_khaled (it's your custom overrides, won't break anything)
  create_link "$DOTFILES_DIR/hypr_khaled" "$CONFIG_DIR/hypr_khaled"

  # XDG terminals list
  create_link "$DOTFILES_DIR/xdg-terminals.list" "$CONFIG_DIR/xdg-terminals.list"

  # Desktop environment configs (skip if using Omarchy or similar)
  if [[ "$SKIP_DESKTOP" == false ]]; then
    # Note: Main hyprland config should source hypr_khaled/custom.conf
    # Create a minimal hyprland config if it doesn't exist
    if [[ ! -e "$CONFIG_DIR/hypr/hyprland.conf" ]]; then
      mkdir -p "$CONFIG_DIR/hypr"
      cat > "$CONFIG_DIR/hypr/hyprland.conf" << 'EOF'
# Hyprland configuration
# This sources the custom config from dotfiles
source = ~/.config/hypr_khaled/custom.conf

# Add your machine-specific configs below
EOF
      echo "  Created: $CONFIG_DIR/hypr/hyprland.conf"
    fi

    # Waybar
    create_link "$DOTFILES_DIR/waybar" "$CONFIG_DIR/waybar"

    # Wofi
    create_link "$DOTFILES_DIR/wofi" "$CONFIG_DIR/wofi"

    # Fuzzel
    create_link "$DOTFILES_DIR/fuzzel" "$CONFIG_DIR/fuzzel"

    # Wlogout
    create_link "$DOTFILES_DIR/wlogout" "$CONFIG_DIR/wlogout"

    # Swaylock
    create_link "$DOTFILES_DIR/swaylock" "$CONFIG_DIR/swaylock"
  else
    echo "  Skipped desktop configs (waybar, wofi, fuzzel, wlogout, swaylock)"

    # Auto-add source line to existing hyprland.conf (e.g., Omarchy)
    HYPR_CONF="$CONFIG_DIR/hypr/hyprland.conf"
    SOURCE_LINE="source = ~/.config/hypr_khaled/custom.conf"

    if [[ -f "$HYPR_CONF" ]]; then
      if grep -qF "hypr_khaled/custom.conf" "$HYPR_CONF"; then
        echo "  hypr_khaled already sourced in hyprland.conf"
      else
        echo "" >> "$HYPR_CONF"
        echo "# Custom overrides from dotfiles" >> "$HYPR_CONF"
        echo "$SOURCE_LINE" >> "$HYPR_CONF"
        echo "  Added source line to: $HYPR_CONF"
      fi
    else
      echo "  No hyprland.conf found - skipping source injection"
    fi
  fi
fi

# ============================================
# Git configuration
# ============================================
echo ""
echo "Setting up Git configuration..."

# Configure git delta as pager
if command -v delta &>/dev/null; then
  git config --global core.pager "delta"
  git config --global interactive.diffFilter "delta --color-only"
  git config --global delta.navigate true
  git config --global merge.conflictStyle zdiff3
  git config --global delta.line-numbers true
  git config --global delta.side-by-side false

  # Include delta themes
  if [[ -f "$CONFIG_DIR/delta/themes.gitconfig" ]]; then
    git config --global include.path "$CONFIG_DIR/delta/themes.gitconfig"
  fi

  echo "  Configured git to use delta"
fi

# Configure difftastic if available
if command -v difft &>/dev/null; then
  git config --global diff.external difft
  echo "  Configured git to use difftastic"
fi

echo ""
echo "=========================================="
echo "  Configuration linking complete!"
echo "=========================================="

if [[ -d "$BACKUP_DIR" ]]; then
  echo ""
  echo "Backups of existing configs saved to:"
  echo "  $BACKUP_DIR"
fi
