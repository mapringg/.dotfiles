export EDITOR=${EDITOR:-vi}
export VISUAL=${VISUAL:-$EDITOR}
export PLANNOTATOR_PORT=9000
export PLANNOTATOR_SKIP_BROWSER_OPEN=1
export PLANNOTATOR_REMOTE=0

if [[ -d /opt/homebrew ]]; then
  export HOMEBREW_PREFIX=/opt/homebrew
elif [[ -d /home/linuxbrew/.linuxbrew ]]; then
  export HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
fi

typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/.local/share/mise/shims"
  ${HOMEBREW_PREFIX:+"$HOMEBREW_PREFIX/bin"}
  ${HOMEBREW_PREFIX:+"$HOMEBREW_PREFIX/sbin"}
  $path
)

if [[ $OSTYPE == linux* && -d $HOME/Android/Sdk ]]; then
  export ANDROID_HOME="$HOME/Android/Sdk"
  path=("$ANDROID_HOME/emulator" "$ANDROID_HOME/platform-tools" $path)
fi
