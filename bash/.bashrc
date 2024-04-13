[ -f /etc/bashrc ] && . /etc/bashrc

[[ ! "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]] && export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# https://wiki.archlinux.org/title/fish#Setting_fish_as_interactive_shell_only
if command -v fish >/dev/null 2>&1; then
    if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z ${BASH_EXECUTION_STRING} ]]
    then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
        exec fish $LOGIN_OPTION
    fi
fi