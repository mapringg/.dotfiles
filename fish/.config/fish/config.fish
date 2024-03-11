if status is-interactive
    # Commands to run in interactive sessions can go here
    if command -v /opt/homebrew/bin/brew > /dev/null
        /opt/homebrew/bin/brew shellenv | source
    end

    fnm env --use-on-cd | source
    starship init fish | source
    zoxide init fish | source
end
