# Keybindings
function fish_user_key_bindings
    bind \cp history-search-backward
    bind \cn history-search-forward
end

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

# Environment variables
set -gx EDITOR vi
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx CLICOLOR 1

# Add directories to PATH
fish_add_path ~/.local/bin
fish_add_path ~/scripts

# Setup shell integrations
zoxide init fish | source

if status is-interactive
  mise activate fish | source
else
  mise activate fish --shims | source
end
