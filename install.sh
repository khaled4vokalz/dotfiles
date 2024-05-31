#! /usr/bin/env bash

set -o errexit
set -o pipefail
shopt -s nullglob

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
setup_pyenv() {
	sudo apt install -y curl git-core gcc make zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libssl-dev
	git clone https://github.com/pyenv/pyenv.git "$HOME"/.pyenv
	git clone https://github.com/pyenv/pyenv-virtualenv.git "$(pyenv root)"/plugins/pyenv-virtualenv
}

### rust dependencies
setup_rust() {
	curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain stable
}

### nvm (node version manager)
setup_nvm() {
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
}

### neovim (YaY)
setup_neovim() {
	sudo apt install -y neovim
}

### alacritty (awesome terminal emulator)
setup_alacritty() {
	sudo add-apt-repository ppa:aslatter/ppa -y
	sudo apt install -y alacritty
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
	sudo apt install -y curl
	sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
	sudo apt update
	sudo apt install -y brave-browser
}

### VSCode
setup_vscode() {
	wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
	sudo apt install -y code
}

install_tools() {
	setup_zsh
	setup_bat
	setup_lsd
	setup_zoxide
	setup_pyenv
	setup_rust
	setup_nvm
	setup_neovim
	setup_alacritty
	setup_tmux
	setup_starship
	setup_brave_browser
	setup_vscode
}

main() {
	install_tools
}

main "$@"
