typeset -U path
path=("$HOME/.local/bin" $path)

for f in /opt/homebrew/opt/antidote/share/antidote/antidote.zsh /usr/share/zsh-antidote/antidote.zsh; do
  [[ -f $f ]] && source $f
done

if command -v antidote >/dev/null 2>&1; then
  [[ -f $HOME/.zsh_plugins.zsh ]] && source "$HOME/.zsh_plugins.zsh"
fi
