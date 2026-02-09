# dotfiles

Personal configs for various tools that I use.

## Quick Start

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/personal/dotfiles
cd ~/personal/dotfiles
./install.sh
```

The install script auto-detects your OS and runs the appropriate installer.

## Installation Options

### Full Installation

Installs all packages and links all configs:

```bash
./install.sh
```

### For Omarchy / Pre-configured Hyprland Users

Skip desktop environment packages and configs (keeps your existing waybar, wofi, etc.):

```bash
./install.sh --skip-desktop
```

This will:
- Install all CLI tools (neovim, lazygit, wezterm, fd, fzf, etc.)
- Link shell configs (.zshrc, starship, etc.)
- Link editor configs (nvim, lazygit, etc.)
- Skip hyprland, waybar, wofi, fuzzel, wlogout, swaylock
- Auto-inject `source = ~/.config/hypr_khaled/custom.conf` into your existing hyprland.conf

### Only Link Configs (No Package Installation)

If you already have packages installed and just want to link configs:

```bash
./install.sh --skip-packages

# Or directly:
./link-configs.sh
./link-configs.sh --skip-desktop  # Skip desktop env configs
```

### Platform-Specific Installers

Run a specific installer directly:

```bash
./install-mac.sh      # macOS (Homebrew)
./install-arch.sh     # Arch Linux (pacman/yay)
./install-debian.sh   # Debian/Ubuntu (apt)
```

All Linux installers support `--skip-packages` and `--skip-desktop` flags.

## What Gets Installed

### CLI Tools (All Platforms)
| Tool | Description |
|------|-------------|
| zsh + oh-my-zsh | Shell with plugins (autosuggestions, vi-mode) |
| neovim | Text editor |
| tmux | Terminal multiplexer |
| starship | Cross-shell prompt |
| bat | Better `cat` |
| lsd | Better `ls` |
| fd | Better `find` |
| fzf | Fuzzy finder |
| ripgrep | Better `grep` |
| zoxide | Smarter `cd` |
| lazygit | Git TUI |
| lazydocker | Docker TUI |
| yazi | File manager |
| git-delta | Better git diffs |
| difftastic | Structural diff tool |
| btop | System monitor |

### Development Tools
| Tool | Description |
|------|-------------|
| Rust | Via rustup |
| mise | Runtime manager (Python, Node, Ruby, Go, etc.) |
| Go | Go programming language |

### Terminal Emulators
- wezterm (primary)
- alacritty

### GUI Apps
- Brave Browser
- VS Code
- (macOS) Aerospace - tiling window manager

### Linux Desktop Environment
- Hyprland
- Waybar
- Wofi / Fuzzel
- Wlogout
- Swaylock

## Config Locations

After installation, configs are symlinked to:

| Config | Location |
|--------|----------|
| zsh | `~/.zshrc` |
| neovim | `~/.config/nvim` |
| wezterm | `~/.config/wezterm` |
| alacritty | `~/.config/alacritty` |
| tmux | `~/.tmux.conf` |
| starship | `~/.config/starship.toml` |
| lazygit | `~/.config/lazygit` |
| yazi | `~/.config/yazi` |
| hyprland overrides | `~/.config/hypr_khaled` |
| waybar | `~/.config/waybar` |
| wofi | `~/.config/wofi` |

## Post-Installation

1. **Restart terminal** or run `source ~/.zshrc`

2. **Install tmux plugins**: Open tmux and press `prefix + I` (Ctrl-f + I)

3. **Install neovim plugins**: Open neovim, plugins install automatically

4. **(Linux) Select Hyprland**: Log out and select Hyprland as your session

## Directory Structure

```
dotfiles/
├── install.sh           # Auto-detect OS and run installer
├── install-mac.sh       # macOS installer
├── install-arch.sh      # Arch Linux installer
├── install-debian.sh    # Debian/Ubuntu installer
├── link-configs.sh      # Symlink configs only
├── .zshrc               # Zsh configuration
├── .bashrc              # Bash configuration
├── .vimrc               # Vim configuration
├── starship.toml        # Starship prompt config
├── nvim/                # Neovim config (LazyVim)
├── wezterm/             # Wezterm config
├── alacritty/           # Alacritty config
├── tmux/                # Tmux config
├── lazygit/             # Lazygit config
├── yazi/                # Yazi file manager config
├── delta/               # Git delta themes
├── hypr_khaled/         # Hyprland custom overrides
├── waybar/              # Waybar config
├── wofi/                # Wofi launcher config
├── fuzzel/              # Fuzzel launcher config
├── wlogout/             # Wlogout config
├── swaylock/            # Swaylock config
├── wallpapers/          # Desktop wallpapers
└── aerospace/           # macOS Aerospace config
```

## Backup

When linking configs, existing configs are backed up to:
```
~/.dotfiles-backup-YYYYMMDD-HHMMSS/
```
