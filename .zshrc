HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=$HISTSIZE

if [[ -z $SSH_CONNECTION ]]; then
  export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
fi

setopt hist_ignore_all_dups hist_ignore_space
setopt inc_append_history

PROMPT="%n@%m %1~ %# "

bindkey -e

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'

autoload -Uz compinit
compinit

if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git --exclude Library --exclude .cache --exclude node_modules'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git --exclude Library --exclude .cache --exclude node_modules'
fi

(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

if [[ -n ${HOMEBREW_PREFIX:-} ]]; then
  source "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh"
  source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
fi
