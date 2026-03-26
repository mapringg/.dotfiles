.PHONY: setup

setup:
	brew bundle --file Brewfile
	stow --no-folding --target="$$HOME" --restow --verbose=1 .
	mise install
	curl -fsSL https://claude.ai/install.sh | bash
	curl -fsSL https://ampcode.com/install.sh | bash
