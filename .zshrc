export SSH_AUTH_SOCK=~/.bitwarden-ssh-agent.sock
export EDITOR=nvim

if [[ -x /opt/homebrew/bin/brew ]]; then
  BREW_PREFIX="/opt/homebrew"
fi

source_first() {
  local file

  for file in "$@"; do
    if [[ -r "$file" ]]; then
      source "$file"
      return 0
    fi
  done

  return 1
}

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
autoload -Uz compinit
compinit -C

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

source_first \
  "$HOME/.fzf/shell/completion.zsh" \
  "${BREW_PREFIX:+$BREW_PREFIX/opt/fzf/shell/completion.zsh}" \
  /usr/share/fzf/completion.zsh \
  /usr/share/doc/fzf/examples/completion.zsh

source_first \
  "$HOME/.fzf/shell/key-bindings.zsh" \
  "${BREW_PREFIX:+$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh}" \
  /usr/share/fzf/key-bindings.zsh \
  /usr/share/doc/fzf/examples/key-bindings.zsh

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

source_first \
  "${BREW_PREFIX:+$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh}" \
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

source_first \
  "${BREW_PREFIX:+$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh}" \
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
