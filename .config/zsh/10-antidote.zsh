typeset -U path
path=("$HOME/.local/bin" $path)

if [[ -f /opt/homebrew/opt/antidote/share/antidote/antidote.zsh ]]; then
  source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh
fi

if command -v antidote >/dev/null 2>&1; then
  [[ -f $HOME/.zsh_plugins.zsh ]] && source "$HOME/.zsh_plugins.zsh"
fi
