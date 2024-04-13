function fish_title
    echo -n (whoami)@(prompt_hostname):(prompt_pwd -d 0)
end
