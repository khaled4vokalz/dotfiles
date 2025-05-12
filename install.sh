#! /usr/bin/env bash

set -o errexit
set -o pipefail
shopt -s nullglob

install_dependencies() {
  echo "installing some dependencies..."
  sudo apt install -y curl gpg apt-transport-https git
}

### zsh (asesome terminal)
setup_zsh() {
  sudo apt install zsh -y

  # make zsh the default terminal
  chsh -s "$(which zsh)"

  # install O-My-Zsh
  sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
}

### bat (awesome alternative to cat)
setup_bat() {
  sudo apt install -y bat

  # it's installed as batcat in ubuntu :(
  mkdir -p ~/.local/bin
  ln -s /usr/bin/batcat ~/.local/bin/bat
}

### lsd (awesome alternative to native ls)
setup_lsd() {
  sudo apt install -y lsd
}

### zoxide (awesome alternative to native cd)
setup_zoxide() {
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
}

### pyenv (python version manager)
setup_pyenv_old() {
  sudo apt install -y curl git-core gcc make zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libssl-dev
  git clone https://github.com/pyenv/pyenv.git "$HOME"/.pyenv
  git clone https://github.com/pyenv/pyenv-virtualenv.git "$(pyenv root)"/plugins/pyenv-virtualenv
}

### rust dependencies
setup_rust() {
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
}

### nvm (node version manager)
setup_nvm() {
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
}

### neovim (YaY)
setup_neovim() {
  # we need this version 0.11.1 to have support for other plugins like lazygit and stuff ;)
  curl -LO https://github.com/neovim/neovim/releases/download/v0.11.1/nvim-linux-x86_64.tar.gz

  tar --transform='s/^nvim-linux-x86_64/nvim/' -xvzf nvim-linux-x86_64.tar.gz

  sudo cp -r nvim /opt/
  sudo ln -s /opt/nvim/bin/nvim /usr/local/bin/nvim
}

### alacritty (awesome terminal emulator)
setup_alacritty() {
  sudo add-apt-repository ppa:aslatter/ppa -y
  sudo apt update
  sudo apt install -y alacritty
}

### wezterm
setup_wezterm() {
  curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /etc/apt/keyrings/wezterm-fury.gpg
  echo 'deb [signed-by=/etc/apt/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
  sudo apt update
  sudo apt install -y wezterm
}

### tmux (awesome terminal multiplexer)
setup_tmux() {
  sudo apt install -y tmux
  # Add tmux plugin manager
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  # start a server but don't attach to it
  tmux start-server
  # create a new session but don't attach to it either
  tmux new-session -d
  # install the plugins
  ~/.tmux/plugins/tpm/scripts/install_plugins.sh
  # killing the server is not required, I guess
  tmux kill-server
}

### starship
setup_starship() {
  curl -sS https://starship.rs/install.sh | sh -s -- -y
}

### Brave browser
setup_brave_browser() {
  sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  sudo apt update
  sudo apt install -y brave-browser
}

### VSCode
setup_vscode() {
  echo "Adding Microsoft GPG key..."
  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/packages.microsoft.gpg

  echo "Adding VS Code repository..."
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |
    sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null

  echo "Installing Visual Studio Code..."
  sudo apt update
  sudo apt install -y code

  echo "✅ VS Code installed successfully!"

}

setup_pyenv() {
  curl -fsSL https://pyenv.run | bash
}

setup_oh_my_zsh() {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

setup_zsh_plugins() {
  # install zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions

  # install zsh-vi-mode
  git clone https://github.com/jeffreytse/zsh-vi-mode "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-vi-mode
}

setup_lazygit() {
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit -D -t /usr/local/bin/
}

setup_difftool() {
  # for git
  cargo install difft

  # awesome difftool
  curl -Lo delta.deb "https://github.com/dandavison/delta/releases/download/0.18.2/git-delta_0.18.2_amd64.deb"
  sudo dpkg -i delta.deb

  # make delta the default difftool in git
  git config --global core.pager delta
  git config --global interactive.diffFilter 'delta --color-only'
  git config --global delta.navigate true
  git config --global merge.conflictStyle zdiff3
}

install_tools() {
  install_dependencies
  setup_zsh
  setup_oh_my_zsh
  setup_zsh_plugins
  setup_bat
  setup_lsd
  setup_zoxide
  setup_pyenv
  setup_rust
  setup_nvm
  setup_neovim
  setup_lazygit
  setup_difftool
  #setup_alacritty ## skipping alacritty for wezterm
  setup_wezterm
  setup_starship
  setup_brave_browser
  setup_vscode
  setup_tmux
}

main() {
  install_tools
}

main "$@"
