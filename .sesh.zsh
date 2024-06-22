function sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list | fzf --reverse --border-label ' sesh ' --border --prompt '⚡  ')
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}

zle     -N             sesh-sessions
bindkey -M emacs '\ek' sesh-sessions
bindkey -M vicmd '\ek' sesh-sessions
bindkey -M viins '\ek' sesh-sessions
