# Add user's private bin directories to PATH if they exist
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# macOS-specific configurations
if [[ "$(uname)" == "Darwin" ]]; then
    # Homebrew setup for macOS
    if [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    # OrbStack setup for macOS
    source ~/.orbstack/shell/init.zsh 2>/dev/null || :
fi

# Environment variables
export XDG_CONFIG_HOME="$HOME/.config"

# Cross-platform tool configurations
eval "$(mise activate zsh --shims)"
