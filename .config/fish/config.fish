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
set -g hydro_color_pwd '#fabd2f'
set -g hydro_color_git '#b8bb26'
set -g hydro_color_prompt '#928374'
set -g hydro_color_error '#fb4934'
set -g hydro_color_duration '#fe8019'
set -g hydro_fetch true
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
