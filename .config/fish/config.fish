if status is-interactive
    # Commands to run in interactive sessions can go here
end

set fish_greeting
set -x EDITOR nvim

abbr --add l "eza -lah"
abbr --add lg lazygit

fish_add_path /opt/homebrew/bin

mise activate fish | source