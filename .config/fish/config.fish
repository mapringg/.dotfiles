if test -f /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end

alias ls "ls --color"
alias ll "ls -l"
alias l. "ls -al"
alias c clear
alias lg "lazygit"

set -g fish_greeting
set -U fish_key_bindings fish_vi_key_bindings

set -x XDG_CONFIG_HOME "$HOME/.config"
set -x EDITOR vi
set -x FZF_DEFAULT_OPTS "--height 40% --tmux bottom,40% --layout reverse --border top"
set -x FZF_DEFAULT_COMMAND "fd --hidden --strip-cwd-prefix --exclude .git"
set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -x FZF_ALT_C_COMMAND "fd --type=d --hidden --strip-cwd-prefix --exclude .git"
set -x ANDROID_HOME "$HOME/Android/Sdk"

fish_add_path "$HOME/.local/bin"
fish_add_path "$HOME/bin"
fish_add_path "$ANDROID_HOME/emulator"
fish_add_path "$ANDROID_HOME/platform-tools"

if status is-interactive
    mise activate fish --shims | source
    fzf --fish | source
    zoxide init fish | source
    starship init fish | source

    source ~/.config/fish/functions/sesh.fish
    bind \ek sesh-sessions
end
