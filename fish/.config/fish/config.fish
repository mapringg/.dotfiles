set fish_greeting

set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx ANDROID_HOME "$HOME/Library/Android/sdk"
set -gx JAVA_HOME "/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"

set -p fish_function_path $XDG_CONFIG_HOME/fish/my_functions $fish_function_path

# User bin directories
fish_add_path $HOME/bin
fish_add_path $HOME/.local/bin

# Android SDK tools
fish_add_path $ANDROID_HOME/emulator
fish_add_path $ANDROID_HOME/platform-tools

alias ls 'ls --color=auto'
alias ll 'ls -l'
alias la 'ls -al'
alias c 'clear'
alias lag 'lazygit'
alias lad 'lazydocker'

if status --is-interactive
    # Homebrew (macOS)
    # Check if brew command exists before sourcing
    if test -d /opt/homebrew
        /opt/homebrew/bin/brew shellenv | source
    end

    if test -d ~/.orbstack
        source ~/.orbstack/shell/init2.fish 2>/dev/null || :
    end

    # mise (formerly rtx)
    if command -q mise
        mise activate fish --shims | source
    end

    # zoxide (replaces cd)
    if command -q zoxide
        zoxide init fish | source
    end

    # fzf
    if command -q fzf
        fzf --fish | source
    end
end
