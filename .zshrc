HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=$HISTSIZE

setopt hist_ignore_all_dups hist_ignore_space share_history

PROMPT="%n@%m %1~ %# "

bindkey -e

autoload -Uz compinit
compinit

source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"

eval "$(zoxide init zsh)"
