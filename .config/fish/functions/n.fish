function n --description 'Open editor with args or current directory'
    set -l editor vim
    if command -q nvim
        set editor nvim
    end

    if test (count $argv) -eq 0
        $editor .
    else
        $editor $argv
    end
end
