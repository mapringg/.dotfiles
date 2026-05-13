for brew in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [[ -x "$brew" ]] && eval "$("$brew" shellenv)" && break
done

export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR="vi"
export VISUAL="$EDITOR"

path=(
  "$HOME/.local/share/mise/shims"
  "$HOME/.local/bin"
  $path
)
