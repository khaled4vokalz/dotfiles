#!/usr/bin/env bash

set -o errexit
set -o pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "  Dotfiles Installation"
echo "=========================================="

# Detect OS and run appropriate installer
detect_and_install() {
  case "$(uname -s)" in
    Darwin)
      echo "Detected: macOS"
      exec "$DOTFILES_DIR/install-mac.sh" "$@"
      ;;
    Linux)
      if [[ -f /etc/arch-release ]]; then
        echo "Detected: Arch Linux"
        exec "$DOTFILES_DIR/install-arch.sh" "$@"
      elif [[ -f /etc/debian_version ]]; then
        echo "Detected: Debian/Ubuntu"
        exec "$DOTFILES_DIR/install-debian.sh" "$@"
      else
        echo "Error: Unsupported Linux distribution"
        echo ""
        echo "Supported distributions:"
        echo "  - Arch Linux (install-arch.sh)"
        echo "  - Debian/Ubuntu (install-debian.sh)"
        echo ""
        echo "You can run the closest match manually:"
        echo "  ./install-arch.sh   # For Arch-based distros"
        echo "  ./install-debian.sh # For Debian-based distros"
        exit 1
      fi
      ;;
    *)
      echo "Error: Unsupported operating system: $(uname -s)"
      exit 1
      ;;
  esac
}

# Show usage if --help is passed
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo ""
  echo "Usage: ./install.sh [OPTIONS]"
  echo ""
  echo "This script auto-detects your OS and runs the appropriate installer."
  echo ""
  echo "Options (Linux only):"
  echo "  --skip-packages  Skip package installation (only link configs)"
  echo "  --skip-desktop   Skip desktop environment (hyprland, waybar, etc.)"
  echo "                   Useful if you're using Omarchy or similar"
  echo ""
  echo "Available installers:"
  echo "  install-mac.sh     - macOS (uses Homebrew)"
  echo "  install-arch.sh    - Arch Linux (uses pacman/yay)"
  echo "  install-debian.sh  - Debian/Ubuntu (uses apt)"
  echo "  link-configs.sh    - Only link config files (no package installation)"
  echo ""
  exit 0
fi

detect_and_install "$@"
