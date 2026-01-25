function n --description 'Open neovim with args or current directory'
    if test (count $argv) -eq 0
        nvim .
    else
        nvim $argv
    end
end