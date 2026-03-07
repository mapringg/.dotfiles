.PHONY: setup

setup:
	brew bundle --file Brewfile
	stow --no-folding --target="$$HOME" --restow --verbose=1 .
	mise install
	@mkdir -p "$$HOME/.ssh/sockets"
	@mkdir -p "$$HOME/.config/tmux/plugins"
	-@git clone https://github.com/tmux-plugins/tpm "$$HOME/.config/tmux/plugins/tpm" 2>/dev/null
	"$$HOME/.config/tmux/plugins/tpm/bin/install_plugins"
	zsh -c 'source "$$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh" && antidote bundle < "$$HOME/.zsh_plugins.txt" > "$$HOME/.zsh_plugins.zsh"'
	curl -fsSL https://claude.ai/install.sh | bash
	curl -fsSL https://ampcode.com/install.sh | bash
