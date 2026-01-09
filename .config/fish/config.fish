# Disable greeting
set -g fish_greeting

# Homebrew
if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end

# Environment variables
set -gx EDITOR nvim
set -gx SUDO_EDITOR $EDITOR
set -gx BAT_THEME ansi
fish_add_path -g $HOME/bin

# Hydro customization
set -g hydro_symbol_prompt ''
set -g hydro_color_pwd '#e5c890'
set -g hydro_color_git '#a6d189'
set -g hydro_color_prompt '#a5adce'
set -g hydro_color_error '#e78284'
set -g hydro_color_duration '#f4b8e4'
set -g hydro_fetch true
set -g hydro_multiline true
set -g fish_prompt_pwd_dir_length 0

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
