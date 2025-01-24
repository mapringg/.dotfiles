# SESH session management
function sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list -t -c | sort -u | fzf )
    zle reset-prompt > /dev/null 2>&1 || true
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}

zle     -N             sesh-sessions
bindkey -M emacs '\ek' sesh-sessions
bindkey -M vicmd '\ek' sesh-sessions
bindkey -M viins '\ek' sesh-sessions
