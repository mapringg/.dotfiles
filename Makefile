.DEFAULT_GOAL := sync
brew_path := $(shell command -v brew 2>/dev/null || { \
	if [ "$$(uname -s)" = Darwin ]; then printf /opt/homebrew/bin/brew; \
	else printf /home/linuxbrew/.linuxbrew/bin/brew; fi; \
})
brew_prefix := $(patsubst %/bin/brew,%,$(brew_path))
export PATH := $(HOME)/.local/bin:$(HOME)/.local/share/mise/shims:$(brew_prefix)/bin:$(brew_prefix)/sbin:$(PATH)

.PHONY: sync

sync:
	@printf '%s\n' 'syncing'
	@test -x "$(brew_path)" || { printf '%s\n' 'error: homebrew is required' >&2; exit 1; }
	@"$(brew_path)" bundle --file Brewfile --quiet
	@stow --target="$(HOME)" --restow --no-folding .
	@mise install --quiet
	@mise upgrade --quiet
	@if command -v amp >/dev/null 2>&1; then amp update; else curl -fsSL https://ampcode.com/install.sh | bash; fi
	@if command -v claude >/dev/null 2>&1; then claude update; else curl -fsSL https://claude.ai/install.sh | bash; fi
	@if command -v codex >/dev/null 2>&1; then codex update; else curl -fsSL https://chatgpt.com/codex/install.sh | bash; fi
	@curl -fsSL https://plannotator.ai/install.sh | bash -s -- --minimal
