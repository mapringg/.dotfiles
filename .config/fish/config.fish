# Disable greeting
set -g fish_greeting

# Homebrew
if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end

# Environment variables
set -gx EDITOR vim
set -gx SUDO_EDITOR $EDITOR
set -gx BAT_THEME ansi
set -gx SSH_AUTH_SOCK ~/.bitwarden-ssh-agent.sock
fish_add_path -g $HOME/bin

# Tool initializations
if command -q mise
    mise activate fish | source
end

if command -q zoxide
    zoxide init fish | source
end

if command -q fzf
    fzf --fish | source
end
