if status is-interactive
    for file in ~/.config/fish/conf.d/*.fish
        source $file
    end

    if command -q bat
        alias cat 'bat'
    end

    if command -q eza
        alias ls 'eza'
        alias la 'eza -al'
        alias ll 'eza -l'
    end

    if command -q fnm
        fnm env --use-on-cd | source
    end

    if command -q fzf
        fzf --fish | source
    end

    if command -q starship
        starship init fish | source
    end

    if command -q zoxide
        zoxide init fish | source
    end
end
