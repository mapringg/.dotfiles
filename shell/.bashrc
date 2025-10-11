HISTSIZE=32768
HISTFILESIZE=32768
HISTFILE=~/.bash_history
HISTCONTROL=ignoredups:ignorespace:erasedups
shopt -s histappend
shopt -s cmdhist

__dotfiles_sync_history() {
  history -a
}

__dotfiles_set_title() {
  printf '\e]0;%s\a' "${PWD/#$HOME/~}"
}

__dotfiles_prompt_hooks() {
  __dotfiles_sync_history
  __dotfiles_set_title
}

PROMPT_COMMAND="__dotfiles_prompt_hooks${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

export PATH="./bin:$HOME/.local/bin:$PATH"
export EDITOR="code"
export SUDO_EDITOR="$EDITOR"
export BAT_THEME=ansi

if shopt -q progcomp; then
  if [[ -r /etc/profile.d/bash_completion.sh ]]; then
    source /etc/profile.d/bash_completion.sh
  elif [[ -r /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
  fi
fi

bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\eOA": history-search-backward'
bind '"\eOB": history-search-forward'

if command -v mise &>/dev/null; then
  eval "$(mise activate bash --shims)"
fi

if command -v starship &>/dev/null; then
  eval "$(starship init bash)"
else
  PS1=$'\uf0a9 '
fi

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init bash)"
fi

if command -v fzf &>/dev/null; then
  source /usr/share/doc/fzf/examples/key-bindings.bash
fi

zd() {
  if [[ $# -eq 0 ]]; then
    builtin cd ~ || return
  elif [[ -d "$1" ]]; then
    builtin cd "$1" || return
  else
    if z "$@"; then
      printf ' \U000F17A9 '
      pwd
    else
      echo "Error: Directory not found"
    fi
  fi
}

alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias cd='zd'
alias lg='lazygit'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
