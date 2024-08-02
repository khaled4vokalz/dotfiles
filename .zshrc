# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

####################################################### EXPORTS #################################################################
export ZSH="$HOME/.oh-my-zsh"
export XDG_CONFIG_HOME="$HOME/.config"
export PATH=${PATH}:${HOME}/.local/bin 
export TERMINAL="alacritty"
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
export NVM_DIR="$HOME/.nvm"
export PYENV_ROOT="$HOME/.pyenv"

####################################################### SOURCINGS #################################################################

plugins=(git ssh-agent colored-man-pages zsh-autosuggestions kubectl)
source $ZSH/oh-my-zsh.sh
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

# make fzf the default thing for fuzzy searching for zsh
source <(fzf --zsh)

####################################################### ALIASES #########################################################

alias cue="npm run cw"
alias cue-ci="npm ci && npm run cw"
alias jmeter=/opt/jmeter/bin/jmeter
alias enter-nightly='ssh-keygen -f "$HOME/.ssh/known_hosts" -R $NIGHTLY_SERVER && ssh -o StrictHostKeyChecking=accept-new  $USER@$NIGHTLY_SERVER'
alias copy="xclip -selection clipboard"
alias ls="lsd"
alias lzd='lazydocker'
alias lg='lazygit'
alias glo='git log --pretty=format:"%C(yellow)%h %C(blue)%>(12)%ad %C(green)%<(7)%aN%Cred%d %Creset%s"'
alias logout='sudo pkill -u $(whoami)'
# alias tks="tmux kill-session -t $(tmux display-message -p '#S')"
alias fzf="fzf --height 40% --layout reverse --border"
alias fo="fzf --print0 | xargs -0 -o vi"
alias vi=/opt/nvim/bin/nvim


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

# NODE VERSION MANAGER (NVIM)
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

