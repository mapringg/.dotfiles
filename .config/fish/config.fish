status is-interactive || exit

set -g fish_greeting

if test -f /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end

fish_add_path -g ~/.local/bin

set -gx EDITOR nvim
set -gx SUDO_EDITOR $EDITOR
set -gx BAT_THEME ansi
set -gx HOMEBREW_NO_ENV_HINTS 1
set -gx SSH_AUTH_SOCK ~/.bitwarden-ssh-agent.sock
set -gx RIPGREP_CONFIG_PATH ~/.config/ripgrep/ripgreprc

set -g hydro_color_pwd cyan
set -g hydro_color_git cyan
set -g hydro_color_prompt cyan
set -g hydro_color_error cyan

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

abbr -a a amp
abbr -a d docker
abbr -a l lazygit
abbr -a o opencode

if command -q zoxide
    zoxide init fish --cmd cd | source
end

if command -q fzf
    fzf --fish | source
end

if command -q direnv
    direnv hook fish | source
end

bind \cg tmux-sessionizer
