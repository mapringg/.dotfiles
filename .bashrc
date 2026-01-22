# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Platform detection
OS="$(uname -s)"

# Source Omarchy defaults on Linux (if available)
if [[ -f ~/.local/share/omarchy/default/bash/rc ]]; then
    source ~/.local/share/omarchy/default/bash/rc

# Replicate Omarchy setup on macOS
elif [[ "$OS" == "Darwin" ]]; then

    # ===== HOMEBREW =====
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    # ===== SHELL SETTINGS (omarchy/shell) =====
    shopt -s histappend
    HISTCONTROL=ignoreboth
    HISTSIZE=32768
    HISTFILESIZE="${HISTSIZE}"

    # Bash completion (Homebrew path)
    if [[ -f /opt/homebrew/etc/profile.d/bash_completion.sh ]]; then
        source /opt/homebrew/etc/profile.d/bash_completion.sh
    fi

    # Ensure command hashing is off for mise
    set +h

    # ===== ENVIRONMENT (omarchy/envs) =====
    export EDITOR="vim"
    export SUDO_EDITOR="$EDITOR"
    export BAT_THEME=ansi
    export HOMEBREW_NO_ENV_HINTS=1

    # ===== ALIASES (omarchy/aliases) =====

    # File system - eza
    if command -v eza &> /dev/null; then
        alias ls='eza -lh --group-directories-first --icons=auto'
        alias lsa='ls -a'
        alias lt='eza --tree --level=2 --long --icons --git'
        alias lta='lt -a'
    fi

    # fzf with bat preview
    alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

    # zoxide smart cd
    if command -v zoxide &> /dev/null; then
        alias cd="zd"
        zd() {
            if [ $# -eq 0 ]; then
                builtin cd ~ && return
            elif [ -d "$1" ]; then
                builtin cd "$1"
            else
                z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
            fi
        }
    fi

    # Directories
    alias ..='cd ..'
    alias ...='cd ../..'
    alias ....='cd ../../..'

    # Tools
    alias c='opencode'
    alias d='docker'
    alias r='rails'
    n() { if [ "$#" -eq 0 ]; then vim .; else vim "$@"; fi; }

    # Git
    alias g='git'
    alias gcm='git commit -m'
    alias gcam='git commit -a -m'
    alias gcad='git commit -a --amend'

    # ===== TOOL INIT (omarchy/init) =====

    if command -v mise &> /dev/null; then
        eval "$(mise activate bash)"
    fi

    if command -v starship &> /dev/null; then
        eval "$(starship init bash)"
    fi

    if command -v zoxide &> /dev/null; then
        eval "$(zoxide init bash)"
    fi

    if command -v fzf &> /dev/null; then
        # Homebrew fzf paths
        if [[ -f /opt/homebrew/opt/fzf/shell/completion.bash ]]; then
            source /opt/homebrew/opt/fzf/shell/completion.bash
        fi
        if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.bash ]]; then
            source /opt/homebrew/opt/fzf/shell/key-bindings.bash
        fi
    fi
fi

# ===== PERSONAL CUSTOMIZATIONS (both platforms) =====

# Bitwarden SSH agent
export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"

# Ripgrep config
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"

# fd with hidden and case-insensitive by default
alias fd='fd --hidden --ignore-case'

# Window title - show current directory name
function set_win_title(){
    echo -ne "\033]0; ${PWD##*/} \007"
}
starship_precmd_user_func="set_win_title"
