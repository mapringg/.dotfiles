if [[ -d /opt/homebrew ]]; then
  export HOMEBREW_PREFIX=/opt/homebrew
  export HOMEBREW_CELLAR=/opt/homebrew/Cellar
  export HOMEBREW_REPOSITORY=/opt/homebrew
elif [[ -d /home/linuxbrew/.linuxbrew ]]; then
  export HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
  export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
  export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX/Homebrew"
fi

export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR="vi"
export VISUAL="$EDITOR"

[[ -n ${HOMEBREW_PREFIX:-} ]] && export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}"

typeset -U path PATH
user_path=(
  ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/bin}
  ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/sbin}
  "$HOME/.local/share/mise/shims"
  "$HOME/.local/bin"
)

if [[ $OSTYPE == linux* ]]; then
  export ANDROID_HOME="$HOME/Android/Sdk"
  user_path+=(
    "$ANDROID_HOME/emulator"
    "$ANDROID_HOME/platform-tools"
  )
fi

path=($user_path $path)
export PATH
