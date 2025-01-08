function sesh-sessions
    # Run fzf and capture the session
    set -l session (sesh list -t -c | fzf)

    # If no session is selected (e.g., user cancels), reset the prompt and return
    if test -z "$session"
        commandline -f repaint # Force Fish to redraw the prompt
        return
    end

    # Connect to the selected session
    sesh connect $session

    # Ensure the prompt is reset after the session ends
    commandline -f repaint
end
