# .bash_profile

# Get the aliases and functions
[ -f ~/.bashrc ] && . ~/.bashrc

# User specific environment and startup programs
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    export NVD_BACKEND=direct
    export MOZ_DISABLE_RDD_SANDBOX=1
fi
