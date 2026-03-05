.PHONY: help deps link setup tmux tools zsh

help:
	@printf "%s\n" \
		"  deps     Install brew packages" \
		"  link     Symlink dotfiles (stow)" \
		"  setup    deps + link + tools + tmux + zsh" \
		"  tmux     Install TPM plugins" \
		"  tools    Install mise tools" \
		"  zsh      Install zsh plugins"

deps:
	brew bundle --file Brewfile

link:
	stow --no-folding --target="$$HOME" --restow --verbose=1 .

setup: deps link tools tmux zsh

tmux:
	@mkdir -p "$$HOME/.config/tmux/plugins"
	@[ -d "$$HOME/.config/tmux/plugins/tpm" ] || git clone https://github.com/tmux-plugins/tpm "$$HOME/.config/tmux/plugins/tpm"
	"$$HOME/.config/tmux/plugins/tpm/bin/install_plugins"

tools:
	mise install

zsh:
	zsh -c 'source "$$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh" && antidote bundle < "$$HOME/.zsh_plugins.txt" > "$$HOME/.zsh_plugins.zsh"'
