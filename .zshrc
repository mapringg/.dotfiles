[[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$USER.zsh" ]] && source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$USER.zsh"

[[ $- != *i* ]] && return

zsh_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

if [[ -d "$zsh_config_dir" ]]; then
	shopt -s nullglob 2>/dev/null || setopt nullglob 2>/dev/null
	for f in "$zsh_config_dir"/[0-9][0-9]-*.zsh; do
		[[ -f $f ]] && source "$f"
	done
	shopt -u nullglob 2>/dev/null || unsetopt nullglob 2>/dev/null
fi

[[ -f $HOME/.p10k.zsh ]] && source "$HOME/.p10k.zsh"
