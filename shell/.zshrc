# History settings
HISTSIZE=30
SAVEHIST=30
HISTFILE=~/.zsh_history

# Environment variables
export PATH="./bin:$HOME/.local/bin:$PATH"
export EDITOR=vim
export SUDO_EDITOR="$EDITOR"

# Completion
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Key bindings
bindkey -e

# Tool integrations
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh --shims)"
fi

# Source local overrides if they exist
if [[ -f ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi
