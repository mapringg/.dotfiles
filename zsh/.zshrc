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
alias lg='lazygit'
alias ld='lazydocker'

# Environment variables
export XDG_CONFIG_HOME="$HOME/.config"

# Git prompt using vcs_info
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' formats '(%b)'
precmd() { vcs_info }
PROMPT='%F{cyan}%~%f %F{yellow}${vcs_info_msg_0_}%f ❯ '

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY          # share history across multiple zsh sessions
setopt APPEND_HISTORY         # append to history
setopt INC_APPEND_HISTORY     # add commands to history as they are typed
setopt HIST_EXPIRE_DUPS_FIRST # expire duplicates first
setopt HIST_IGNORE_DUPS       # do not store duplications
setopt HIST_FIND_NO_DUPS      # ignore duplicates when searching
setopt HIST_REDUCE_BLANKS     # removes blank lines from history
setopt HIST_VERIFY            # show command with history expansion before running it

# macOS specific settings
export ANDROID_HOME="$HOME/Library/Android/sdk"
export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"
    
# PATH modification for macOS
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"

# Interactive shell setup
if [[ -o interactive ]]; then
    # macOS (Homebrew) paths
    local brew_prefix=$(brew --prefix)
    source $brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source $brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

    # Common interactive shell tools
    if command -v fzf &> /dev/null; then
        source <(fzf --zsh 2>/dev/null)
    fi
    
    if command -v zoxide &> /dev/null; then
        eval "$(zoxide init zsh)"
    fi

    # Completion system
    autoload -Uz compinit
    if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
        compinit
    else
        compinit -C
    fi
    
    # Load zsh-completions
    if [ -d $brew_prefix/share/zsh-completions ]; then
        fpath=($brew_prefix/share/zsh-completions $fpath)
    fi
    
    # Completion styling
    zstyle ':completion:*' menu select
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
fi
