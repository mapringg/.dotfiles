BREW_PREFIX="/opt/homebrew"

source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=$HISTSIZE

setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_save_no_dups
setopt sharehistory

FPATH="$BREW_PREFIX/share/zsh-completions:$FPATH"

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

autoload -Uz compinit
compinit -C

source "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
source "$BREW_PREFIX/opt/fzf/shell/completion.zsh"

eval "$(zoxide init zsh)"
