# Exit if not interactive
status is-interactive || exit

# Disable greeting
set -g fish_greeting

# Homebrew
if test -f /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end

# Path
fish_add_path -g ~/.local/bin

# Environment
if command -q nvim
    set -gx EDITOR nvim
else
    set -gx EDITOR vim
end
set -gx SUDO_EDITOR $EDITOR
set -gx BAT_THEME ansi
set -gx HOMEBREW_NO_ENV_HINTS 1
set -gx SSH_AUTH_SOCK ~/.bitwarden-ssh-agent.sock
set -gx RIPGREP_CONFIG_PATH ~/.config/ripgrep/ripgreprc

# Hydro prompt
set -g hydro_color_pwd cyan
set -g hydro_color_git cyan
set -g hydro_color_prompt cyan
set -g hydro_color_error cyan

# Aliases
if command -q eza
    alias ls 'eza -lh --group-directories-first --icons=auto'
    alias lsa 'ls -a'
    alias lt 'eza --tree --level=2 --long --icons --git'
    alias lta 'lt -a'
end

alias ff "fzf --preview 'bat --style=numbers --color=always {}'"
alias fd 'fd --hidden --ignore-case'

alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'

abbr -a o opencode
abbr -a d docker
abbr -a l lazygit

# Tool init (keep last - some override aliases like cd)
if command -q zoxide
    zoxide init fish --cmd cd | source
end

if command -q fzf
    fzf --fish | source
end
