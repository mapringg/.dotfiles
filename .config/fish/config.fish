set -g fish_greeting ""

# History
set -g HISTSIZE 5000
set -g HISTFILE ~/.fish_history
set -g fish_history_file ~/.fish_history

# Aliases
alias ls='ls --color=auto'
alias ll='ls -l'
alias la='ls -la'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias a='alias'
alias lg='lazygit'
alias g='git'
alias zl='zellij'

# Environment variables
set -gx EDITOR vi
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx CLICOLOR 1

# Setup shell integrations
zoxide init fish | source

if status is-interactive
  mise activate fish | source
else
  mise activate fish --shims | source
end

oh-my-posh init fish --config $HOME/.config/ohmyposh/config.toml | source
