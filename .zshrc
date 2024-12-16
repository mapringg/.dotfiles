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
export PATH="$HOME/.local/bin:$HOME/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"

# Interactive shell setup
if [[ -o interactive ]]; then
    source <(fzf --zsh)
    eval "$(zoxide init zsh)"
fi