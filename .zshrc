# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Clone necessary repositories if they don't exist
POWERLEVEL10K_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/powerlevel10k"
ZSH_SYNTAX_HIGHLIGHTING_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/zsh-syntax-highlighting"
ZSH_AUTOSUGGESTIONS_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/zsh-autosuggestions"

[ ! -d $POWERLEVEL10K_DIR ] && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $POWERLEVEL10K_DIR
[ ! -d $ZSH_SYNTAX_HIGHLIGHTING_DIR ] && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_SYNTAX_HIGHLIGHTING_DIR
[ ! -d $ZSH_AUTOSUGGESTIONS_DIR ] && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_AUTOSUGGESTIONS_DIR

# Source the plugins and themes
source $POWERLEVEL10K_DIR/powerlevel10k.zsh-theme
source $ZSH_SYNTAX_HIGHLIGHTING_DIR/zsh-syntax-highlighting.zsh
source $ZSH_AUTOSUGGESTIONS_DIR/zsh-autosuggestions.zsh

# Load completions
autoload -Uz compinit
compinit

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Aliases
alias ls='ls --color=auto'
alias ll='ls -l'
alias la='ls -la'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Environments
export EDITOR="vi"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export XDG_CONFIG_HOME="$HOME/.config"
export CLICOLOR=1
[[ ! $PATH =~ ~/.local/bin ]] && PATH=$PATH:~/.local/bin

# Setup shell integrations
eval "$(zoxide init --cmd cd zsh)"
