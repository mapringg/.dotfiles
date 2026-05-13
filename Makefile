.PHONY: setup

setup:
	brew bundle --file Brewfile
	stow --no-folding --target="$(HOME)" --restow --verbose=1 .
	mise install
	@command -v amp >/dev/null 2>&1 || curl -fsSL https://ampcode.com/install.sh | bash
	@command -v claude >/dev/null 2>&1 || curl -fsSL https://claude.ai/install.sh | bash
