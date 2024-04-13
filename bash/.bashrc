[ -f /etc/bashrc ] && . /etc/bashrc

[[ ! "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]] && export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

if command -v /opt/homebrew/bin/brew >/dev/null 2>&1; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# https://wiki.archlinux.org/title/fish#Setting_fish_as_interactive_shell_only
if command -v fish >/dev/null 2>&1; then
    if [[ $(ps -o comm= -p $$) != "fish" && -z ${BASH_EXECUTION_STRING} ]]
    then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
        exec fish $LOGIN_OPTION
    fi
fi