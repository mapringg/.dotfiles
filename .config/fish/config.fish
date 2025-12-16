set -U fish_greeting
set -Ux EDITOR code

if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end