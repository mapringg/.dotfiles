function n --description 'Open vim with args or current directory'
    if test (count $argv) -eq 0
        vim .
    else
        vim $argv
    end
end
