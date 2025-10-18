# Zsh configuration for macOS setup
# History settings
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt APPEND_HISTORY

HISTSIZE=32768
SAVEHIST=32768
HISTFILE=~/.zsh_history

# Environment variables
export PATH="./bin:$HOME/.local/bin:$PATH"
if command -v code &>/dev/null; then
  export EDITOR="code"
else
  export EDITOR="${EDITOR:-vim}"
fi
export SUDO_EDITOR="$EDITOR"
export BAT_THEME=ansi

# Completion with caching for performance
autoload -Uz compinit
# Cache completion if dump file is newer than 24 hours
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Key bindings
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Tool integrations
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh --shims)"
fi

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

if command -v fzf &>/dev/null; then
  source <(fzf --zsh)
fi

# Prompt
PS1=$'\uf0a9 '

# Prompt command hook for window title
precmd() {
  print -Pn "\e]0;%~\a"
}

# Directory navigation function
zd() {
  if [ $# -eq 0 ]; then
    builtin cd ~ || return 1
  elif [ -d "$1" ]; then
    builtin cd "$1" || return 1
  else
    if z "$@"; then
      printf " \U000F17A9 "
      pwd
      return 0
    else
      echo "Error: Directory not found" >&2
      return 1
    fi
  fi
}

# Aliases
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

# Source local overrides if they exist
if [[ -f ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi
