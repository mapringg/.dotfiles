function load_secrets
    if test -f ~/.secrets
        source ~/.secrets
        echo "Secrets loaded."
    else
        echo "No secrets file found."
    end
end