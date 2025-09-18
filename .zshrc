# =============================================================================
# ZSH CONFIGURATION
# =============================================================================

# -----------------------------------------------------------------------------
# Shell Options & History
# -----------------------------------------------------------------------------
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt APPEND_HISTORY

HISTSIZE=32768
SAVEHIST=32768
HISTFILE=~/.zsh_history

# Set complete path
export PATH="./bin:$HOME/.local/bin:$PATH"

# -----------------------------------------------------------------------------
# Environment Variables
# -----------------------------------------------------------------------------
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"
export BAT_THEME=ansi

# -----------------------------------------------------------------------------
# ZSH Completion System
# -----------------------------------------------------------------------------
autoload -Uz compinit
compinit

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Menu selection for completion
zstyle ':completion:*' menu select

# Color completion based on LS_COLORS
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# -----------------------------------------------------------------------------
# Key Bindings
# -----------------------------------------------------------------------------
# Use emacs key bindings
bindkey -e

# History search with arrow keys
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# -----------------------------------------------------------------------------
# Tool Initialization
# -----------------------------------------------------------------------------
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh --shims)"
fi

if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

if command -v fzf &>/dev/null; then
  source <(fzf --zsh)
fi

# -----------------------------------------------------------------------------
# Prompt Configuration
# -----------------------------------------------------------------------------
PS1=$'\uf0a9 '
# Set terminal title to current directory
precmd() {
  print -Pn "\e]0;%~\a"
}

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------

# Smart cd with zoxide fallback
zd() {
  if [ $# -eq 0 ]; then
    builtin cd ~ && return
  elif [ -d "$1" ]; then
    builtin cd "$1"
  else
    z "$@" && printf " \U000F17A9 " && pwd || echo "Error: Directory not found"
  fi
}

# Compression utilities
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------

# File system
alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias cd="zd"

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Tools
alias g='git'
alias d='docker'

# Git
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'

# Compression
alias decompress="tar -xzf"