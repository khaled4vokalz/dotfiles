# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

####################################################### EXPORTS #################################################################
export ZSH="$HOME/.oh-my-zsh"
export XDG_CONFIG_HOME="$HOME/.config"
export PATH=${PATH}:${HOME}/.local/bin 
export TERMINAL="wezterm"
# this is needed for jmeter to be able to zoom in it's default GUI is HI Res monitors
# REF: https://jmeter.apache.org/usermanual/hints_and_tips.html#hidpi
export JVM_ARGS="-Dsun.java2d.uiScale=200%"
GPG_TTY=$(tty)
export GPG_TTY
export EDITOR=nvim
# JAVA
export JAVA_HOME=/usr/lib/jvm/java-current
export PATH=${PATH}:${JAVA_HOME}/bin
# GO
export PATH=$PATH:/usr/local/go/bin
export PATH=${PATH}:${HOME}/go/bin 
export NVM_DIR="$HOME/.config/nvm"
export PYENV_ROOT="$HOME/.pyenv"

####################################################### SOURCINGS #################################################################

function zvm_config() {
  # enable next line if we want to get into the terminal in NORMAL VIM mode
  # ZVM_LINE_INIT_MODE=$ZVM_MODE_NORMAL

  # Retrieve default cursor styles
  local ncur=$(zvm_cursor_style $ZVM_NORMAL_MODE_CURSOR)
  local icur=$(zvm_cursor_style $ZVM_NORMAL_MODE_CURSOR)

  # Append your custom color for your cursor
  ZVM_INSERT_MODE_CURSOR=$icur'\e\e]12;#85e872\a'
  ZVM_NORMAL_MODE_CURSOR=$ncur'\e\e]12;#ffffff\a'
  zvm_after_init_commands+=('source <(fzf --zsh)')
}

# make sure the zsh-vi-mode plugin is cloned first
# git clone https://github.com/jeffreytse/zsh-vi-mode $ZSH_CUSTOM/plugins/zsh-vi-mode

plugins=(git ssh-agent colored-man-pages zsh-autosuggestions kubectl zsh-vi-mode)
source $ZSH/oh-my-zsh.sh
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

# make fzf the default thing for fuzzy searching for zsh
source <(fzf --zsh)

####################################################### ALIASES #########################################################

alias copy="xclip -selection clipboard"
alias ls="lsd"
alias lzd='lazydocker'
alias lg='lazygit'
alias glo='git log --pretty=format:"%C(yellow)%h %C(blue)%>(12)%ad %C(green)%<(7)%aN%Cred%d %Creset%s"'
alias logout='sudo pkill -u $(whoami)'
# alias tks="tmux kill-session -t $(tmux display-message -p '#S')"
alias fzf="fzf --height 40% --layout reverse --border"
alias vi=/usr/bin/nvim
alias fo="fzf --print0 | xargs -0 -o nvim"


####################################################### User functions #########################################################

autoload -U compinit; compinit
#prompt_context() {
#  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
#    prompt_segment black default "%(!.%{%F{yellow}%}.)$USER"
#  fi
#}

# create file and directory in one go
function mkfile() {
    mkdir -p  "$1" && touch  "$1"/"$2"
}

# NODE VERSION MANAGER (NVM)
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

autoload -U add-zsh-hook
load-nvmrc() {
  [[ -a .nvmrc ]] || return
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}

eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"

### PYTHON
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

