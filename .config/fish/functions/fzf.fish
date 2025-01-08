# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function is the base path to start traversal
function _fzf_compgen_path
    fd --hidden --exclude .git . $argv[1]
end

# Use fd to generate the list for directory completion
function _fzf_compgen_dir
    fd --type=d --hidden --exclude .git . $argv[1]
end