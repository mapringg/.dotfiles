# Exit if not interactive
status is-interactive || exit

# Disable greeting
set -g fish_greeting

# Homebrew
if test -f /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end

# Environment
if command -q nvim
    set -gx EDITOR nvim
else
    set -gx EDITOR vim
end
set -gx SUDO_EDITOR $EDITOR
set -gx BAT_THEME ansi
set -gx HOMEBREW_NO_ENV_HINTS 1

# Aliases
if command -q eza
    alias ls 'eza -lh --group-directories-first --icons=auto'
    alias lsa 'ls -a'
    alias lt 'eza --tree --level=2 --long --icons --git'
    alias lta 'lt -a'
end

alias ff "fzf --preview 'bat --style=numbers --color=always {}'"

alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'

alias c opencode
alias d docker

# Tool init
if command -q zoxide
    zoxide init fish --cmd cd | source
end

if command -q fzf
    fzf --fish | source
end

# Personal
fish_add_path -g ~/.local/bin
set -gx SSH_AUTH_SOCK ~/.bitwarden-ssh-agent.sock
set -gx RIPGREP_CONFIG_PATH ~/.config/ripgrep/ripgreprc
alias fd 'fd --hidden --ignore-case'
