# Source global definitions
if [ -f /etc/zshrc ]; then
    . /etc/zshrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# User specific aliases and functions
if [ -d ~/.zshrc.d ]; then
    for rc in ~/.zshrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# Aliases
alias ls='ls --color'
alias ll='ls -l'
alias la='ls -al'
alias c='clear'
alias lag='lazygit'
alias lad='lazydocker'

# Environment variables
export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR=vi
export ANDROID_HOME="$HOME/Library/Android/sdk"
export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"

# PATH modification
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"

# Interactive shell setup
if [[ -o interactive ]]; then
    source <(fzf --zsh)
    eval "$(zoxide init zsh)"
fi
