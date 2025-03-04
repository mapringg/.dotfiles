# .zprofile for macOS
# This file is executed for login shells

# Source global definitions
if [ -f /etc/zshrc ]; then
    . /etc/zshrc
fi

# Set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# Set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# Homebrew setup for macOS
eval "$(/opt/homebrew/bin/brew shellenv)"

# Add any other local zprofile configurations here
eval "$(mise activate zsh --shims)"
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
