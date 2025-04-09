set fish_greeting

set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx ANDROID_HOME "$HOME/Library/Android/sdk"
set -gx JAVA_HOME "/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"

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

    # Hydro prompt colors (Cursor Midnight theme)
    set -g hydro_color_pwd "#81a1c1"      # Blue for path (palette 4)
    set -g hydro_color_git "#a3be8c"      # Green for git info (palette 2)
    set -g hydro_color_prompt "#ebcb8b"   # Yellow for prompt symbol (palette 3)
    set -g hydro_color_error "#bf616a"    # Red for errors (palette 1)
    set -g hydro_color_duration "#88c0d0" # Cyan for duration (palette 6)
    set -g hydro_color_start "#e5e9f0"    # Light gray for start (palette 7)

    # Optional: Configure other Hydro settings
    if not string match -q "$TERM_PROGRAM" "vscode"
        set -g hydro_multiline true       # Show prompt on new line
    end
end
