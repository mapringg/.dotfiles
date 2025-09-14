# =============================================================================
# BASH CONFIGURATION
# =============================================================================

# -----------------------------------------------------------------------------
# Shell Options & History
# -----------------------------------------------------------------------------
shopt -s histappend
HISTCONTROL=ignoreboth
HISTSIZE=32768
HISTFILESIZE="${HISTSIZE}"

force_color_prompt=yes
color_prompt=yes

# Set complete path
export PATH="./bin:$HOME/.local/bin:$PATH"
set +h

# -----------------------------------------------------------------------------
# Environment Variables
# -----------------------------------------------------------------------------
export EDITOR="vi"
export SUDO_EDITOR="$EDITOR"
export BAT_THEME=ansi

# -----------------------------------------------------------------------------
# Autocompletion
# -----------------------------------------------------------------------------
if [[ -z "${BASH_COMPLETION_VERSINFO:-}" ]]; then
  if [[ -r "$(brew --prefix 2>/dev/null)/etc/profile.d/bash_completion.sh" ]]; then
    source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
  fi
fi

# -----------------------------------------------------------------------------
# Tool Initialization
# -----------------------------------------------------------------------------
if command -v mise &> /dev/null; then
  eval "$(mise activate bash --shims)"
fi

if command -v starship &> /dev/null; then
  eval "$(starship init bash)"
fi

if command -v zoxide &> /dev/null; then
  eval "$(zoxide init bash)"
fi

if command -v fzf &> /dev/null; then
  eval "$(fzf --bash)"
fi

# -----------------------------------------------------------------------------
# Prompt Configuration
# -----------------------------------------------------------------------------
PS1=$'\uf0a9 '
PS1="\[\e]0;\w\a\]$PS1"

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
alias l='lazygit'
alias n='nlx create-next-app@latest'
alias h='nlx hono@latest'
alias s='nlx shadcn@latest add'

# Git
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'

# Compression
alias decompress="tar -xzf"
