.DEFAULT_GOAL := help
.PHONY: help setup update prune

help: ## List available commands
	@awk 'BEGIN {FS = ":.*## "; printf "Usage: make <command>\n\nCommands:\n"} /^[a-zA-Z0-9_-]+:.*## / {printf "  %-24s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: ## Set up all dotfiles and tools
	@printf 'dotfiles: setting up\n'
	@brew bundle --file Brewfile --quiet
	@stow --target="$(HOME)" --restow --no-folding .
	@for manifest in .config/herdr/plugins/*/herdr-plugin.toml; do \
		[ -e "$$manifest" ] || continue; \
		herdr plugin link "$$(dirname "$$manifest")" >/dev/null; \
	done
	@mise install --quiet
	@command -v amp >/dev/null 2>&1 || curl -fsSL https://ampcode.com/install.sh | bash
	@command -v claude >/dev/null 2>&1 || curl -fsSL https://claude.ai/install.sh | bash
	@command -v codex >/dev/null 2>&1 || curl -fsSL https://chatgpt.com/codex/install.sh | bash
	@scripts/setup-codex.mjs
	@[ "$$(uname -s)" = "Linux" ] && scripts/setup-t3code.sh || true
	@[ "$$(uname -s)" = "Linux" ] && scripts/setup-gnome-desktop.sh || true
	@[ "$$(uname -s)" = "Linux" ] && scripts/setup-font.sh || true
	@[ "$$(uname -s)" = "Darwin" ] && scripts/setup-tunnel.sh install || true

update: ## Update installed tools
	@printf 'dotfiles: updating\n'
	@brew update --quiet
	@brew bundle --file Brewfile --quiet
	@brew bundle cleanup --file Brewfile --force --quiet
	@brew upgrade --quiet
	@brew cleanup --quiet
	@mise upgrade --quiet
	@command -v claude >/dev/null 2>&1 && claude update || true
	@command -v amp >/dev/null 2>&1 && amp update || true
	@command -v codex >/dev/null 2>&1 && codex update || true
	@npx --yes skills@latest remove --all --global --agent codex --yes
	@for section in engineering productivity; do \
		npx --yes skills@latest add "mattpocock/skills/skills/$$section" --skill '*' --global --agent codex --yes; \
	done
	@[ "$$(uname -s)" = "Linux" ] && command -v t3 >/dev/null 2>&1 && scripts/setup-t3code.sh "$$(t3 --version 2>/dev/null | grep -q nightly && echo nightly || echo stable)" || true

prune: ## Delete broken symlinks managed by this repository
	@repo="$$(basename "$(CURDIR)")"; \
	prune_in() { find "$$1" $$2 -type l -lname "*$$repo/*" ! -exec test -e {} \; -print -delete; }; \
	prune_in "$(HOME)" "-maxdepth 1"; \
	for dir in $$(git ls-tree -d --name-only HEAD); do \
		[ -d "$(HOME)/$$dir" ] && prune_in "$(HOME)/$$dir"; \
	done; \
	true
