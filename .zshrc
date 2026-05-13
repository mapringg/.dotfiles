path=($user_path $path)
unset user_path

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=$HISTSIZE

setopt hist_ignore_space hist_verify

PROMPT="%n@%m %1~ %# "

bindkey -e
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"

autoload -Uz compinit
zmodload zsh/datetime
zmodload zsh/stat
zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
zcompdump_mtime=$(zstat +mtime "$zcompdump" 2>/dev/null)
if [[ -z $zcompdump_mtime ]] || (( EPOCHSECONDS - zcompdump_mtime > 86400 )); then
  compinit -d "$zcompdump"
else
  compinit -C -d "$zcompdump"
fi
unset zcompdump zcompdump_mtime

if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  export FZF_TMUX_HEIGHT=100%
fi

if [[ -o zle && -t 0 && -n ${HOMEBREW_PREFIX:-} ]]; then
  [[ -r "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh" ]] &&
    source "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh"
  [[ -r "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ]] &&
    source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
fi

(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
(( $+commands[atuin] )) && eval "$(atuin init zsh)"

dev() {
  mise exec node@lts -- node "$HOME/.dotfiles/scripts/dev.mjs" "$@"
}

wave() {
  mise exec node@lts -- node "$HOME/.dotfiles/scripts/wave.mjs" "$@"
}

if [[ -o zle && -t 0 && -n ${HOMEBREW_PREFIX:-} ]]; then
  [[ -r "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] &&
    source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [[ -r "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] &&
    source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
