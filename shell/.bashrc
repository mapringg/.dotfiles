# History settings
HISTSIZE=500
HISTFILESIZE=500
HISTFILE=~/.bash_history
HISTCONTROL=ignoredups:ignorespace:erasedups
shopt -s histappend
shopt -s cmdhist

# Environment variables
export PATH="./bin:$HOME/.local/bin:$PATH"
export EDITOR=vim
export SUDO_EDITOR="$EDITOR"

# Bash completion
if shopt -q progcomp; then
  if [[ -r /etc/profile.d/bash_completion.sh ]]; then
    source /etc/profile.d/bash_completion.sh
  elif [[ -r /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
  fi
fi

# Readline bindings
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'

# Tool integrations
if command -v mise &>/dev/null; then
  eval "$(mise activate bash --shims)"
fi

# Source local overrides if they exist
if [[ -f ~/.bashrc.local ]]; then
  source ~/.bashrc.local
fi
