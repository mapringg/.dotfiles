setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt APPEND_HISTORY

HISTSIZE=32768
SAVEHIST=32768
HISTFILE=~/.zsh_history

export PATH="./bin:$HOME/.local/bin:$PATH"
export EDITOR="code"
export SUDO_EDITOR="$EDITOR"
export BAT_THEME=ansi

autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

if command -v mise &>/dev/null; then
  eval "$(mise activate zsh --shims)"
fi

if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
else
  PS1=$'\uf0a9 '
fi

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

if command -v fzf &>/dev/null; then
  source <(fzf --zsh)
fi

precmd() {
  print -Pn "\e]0;%~\a"
}

zd() {
  if [ $# -eq 0 ]; then
    builtin cd ~ && return
  elif [ -d "$1" ]; then
    builtin cd "$1"
  else
    z "$@" && printf " \U000F17A9 " && pwd || echo "Error: Directory not found"
  fi
}

alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias cd='zd'
alias lg='lazygit'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
