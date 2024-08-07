# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Setup zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Add zsh plugins
zinit ice depth=1
zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add oh-my-zsh plugins
zinit snippet OMZP::git
zinit snippet OMZL::git.zsh
zinit snippet OMZP::gh

# Load completions
fpath+=("$ZSH_CACHE_DIR/completions")
autoload -Uz compinit
compinit
zinit cdreplay -q

# Load edit command line
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Setup sesh for tmux session management
[[ ! -f ~/.sesh.zsh ]] || source ~/.sesh.zsh

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:*' fzf-flags --height=100
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='eza -lh --group-directories-first --icons'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lg="lazygit"
alias ce="gh copilot explain"
alias cs="gh copilot suggest"
alias gpl="gh pr list"
alias gpc="gh pr checkout"
alias gpv="gh pr view"
alias gpm="gh pr merge"
alias gpr="gh pr review"
alias sa="alias | grep"
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Environments
export EDITOR="vi"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export XDG_CONFIG_HOME="$HOME/.config"
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
  --height=100 \
  --highlight-line \
  --info=inline-right \
  --ansi \
  --layout=reverse \
  --border\
  --border-label ' fzf ' \
  --prompt '⚡  ' \
  --color=bg+:#313244 \
  --color=bg:#1e1e2e \
  --color=fg+:#cdd6f4 \
  --color=header:#f38ba8 \
  --color=hl+:#f38ba8 \
  --color=hl:#f38ba8 \
  --color=info:#cba6f7 \
  --color=marker:#f5e0dc \
  --color=pointer:#f5e0dc \
  --color=prompt:#cba6f7 \
  --color=spinner:#f5e0dc \
"
export FZF_DEFAULT_COMMAND="fd -H -E '.git'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
[[ ! $PATH =~ ~/.local/bin ]] && PATH=$PATH:~/.local/bin

# Setup shell integrations
eval "$(fzf --zsh)"
eval "$(mise activate zsh)"
eval "$(zoxide init --cmd cd zsh)"
