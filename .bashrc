# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
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
if [[ -n $PS1 ]]; then
    eval "$(fzf --bash)"
    eval "$(zoxide init bash)"
fi
