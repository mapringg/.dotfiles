# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Setup zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Add zsh plugins
zinit ice depth=1; zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add oh-my-zsh plugins
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::gh
zinit snippet OMZP::fnm

# Load completions
fpath+=("$ZSH_CACHE_DIR/completions")
autoload -Uz compinit && compinit
zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Setup homebrew
[[ -f "/opt/homebrew/bin/brew" ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

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
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
alias ll="ls -l"
alias la="ls -la"
alias lg="lazygit"
alias ld="lazydocker"
alias ce="gh copilot explain"
alias cs="gh copilot suggest"
alias gpl="gh pr list"
alias gpc="gh pr checkout"
alias gpv="gh pr view"
alias gpm="gh pr merge"
alias gpr="gh pr review"
alias agal="alias | grep"
alias wgu='sudo wg-quick up wg0'
alias wgd='sudo wg-quick down wg0'
alias wgs='sudo wg show'

# Environments
export LS_COLORS="di=1;34:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
[ "$(uname -s)" = "Linux" ] && export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
[ "$(uname -s)" = "Linux" ] && export PATH="$PATH:$HOME/.fnm"
[ "$(uname -s)" = "Linux" ] && export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
[[ -d $HOME/go/bin ]] && export PATH="$HOME/go/bin:$PATH"
[ "$(uname -s)" = "Darwin" ] && export PATH=$PATH:/usr/local/bin

# Setup shell integrations
[[ -f $HOME/.cargo/env ]] && source "$HOME/.cargo/env"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ "$(uname -s)" = "Darwin" ] && eval "$(fzf --zsh)"
eval "$(fnm env --use-on-cd)"
eval "$(pyenv init -)"
eval "$(zoxide init --cmd cd zsh)"
