# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

# Detect OS for platform-specific configurations
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS specific settings
    export ANDROID_HOME="$HOME/Library/Android/sdk"
    export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"
    
    # PATH modification for macOS
    export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"
else
    # Linux specific settings (Fedora)
    # Add any Fedora-specific environment variables here
    export ANDROID_HOME="$HOME/Android/Sdk"
    export JAVA_HOME="/usr/lib/jvm/java-17-openjdk"
    export PATH="$JAVA_HOME/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"
fi

# Interactive shell setup
if [[ -o interactive ]]; then
    if [[ "$(uname)" == "Darwin" ]]; then
        # macOS (Homebrew) paths
        source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme
    else
        # Fedora paths
        source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        
        # For powerlevel10k, you may need to install it manually on Fedora
        # via: git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
        # Uncomment the line below after installation:
        source ~/powerlevel10k/powerlevel10k.zsh-theme
    fi

    # Common interactive shell tools
    if command -v fzf &> /dev/null; then
        source <(fzf --zsh 2>/dev/null)
    fi
    
    if command -v zoxide &> /dev/null; then
        eval "$(zoxide init zsh)"
    fi
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
