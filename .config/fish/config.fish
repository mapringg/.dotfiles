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
set -gx RIPGREP_CONFIG_PATH ~/.config/ripgrep/ripgreprc

# Hydro prompt
set -gx hydro_multiline true

# fzf uses fd for faster file/directory searching
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden'
set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden'

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
