# Disable greeting
set -g fish_greeting

# Homebrew
if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end

# Environment variables
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx EDITOR vim
set -gx SUDO_EDITOR $EDITOR
set -gx BAT_THEME ansi
set -gx SSH_AUTH_SOCK ~/.bitwarden-ssh-agent.sock
set -gx RIPGREP_CONFIG_PATH ~/.config/ripgrep/ripgreprc
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

# Hydro prompt
set -gx hydro_multiline true

# Tool initializations
if command -q mise
    mise activate fish | source
end

if command -q zoxide
    zoxide init fish | source
end
