[[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]] && source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

[[ $- != *i* ]] && return

zsh_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

if [[ -d "$zsh_config_dir" ]]; then
    for f in "$zsh_config_dir"/[0-9][0-9]-*.zsh(N); do
        [[ -f $f ]] && source "$f"
    done
fi

[[ -f $HOME/.p10k.zsh ]] && source "$HOME/.p10k.zsh"
