.PHONY: setup update codex-config prune desktop font

setup:
	brew bundle --file Brewfile
	stow --target="$(HOME)" --restow --verbose=1 .
	mise install
	@command -v amp >/dev/null 2>&1 || curl -fsSL https://ampcode.com/install.sh | bash
	@command -v claude >/dev/null 2>&1 || curl -fsSL https://claude.ai/install.sh | bash
	@command -v codex >/dev/null 2>&1 || curl -fsSL https://chatgpt.com/codex/install.sh | CODEX_NON_INTERACTIVE=1 sh
	@$(MAKE) --no-print-directory codex-config
	@[ "$$(uname -s)" = "Linux" ] && $(MAKE) --no-print-directory desktop || true
	@[ "$$(uname -s)" = "Linux" ] && $(MAKE) --no-print-directory font || true

update:
	brew update
	brew bundle --file Brewfile
	brew bundle cleanup --file Brewfile --force
	brew upgrade
	brew cleanup
	mise upgrade
	@command -v claude >/dev/null 2>&1 && claude update || true
	@command -v amp >/dev/null 2>&1 && amp update || true
	@command -v codex >/dev/null 2>&1 && curl -fsSL https://chatgpt.com/codex/install.sh | CODEX_NON_INTERACTIVE=1 sh || true

codex-config:
	@mkdir -p "$(HOME)/.codex"
	@touch "$(HOME)/.codex/config.toml"
	@perl -0pi -e 's/^[ \t]*(approval_policy|default_permissions)[ \t]*=.*\R//mg; s/\A(?:[ \t]*\R)*/approval_policy = "never"\ndefault_permissions = ":danger-full-access"\n\n/s' "$(HOME)/.codex/config.toml"

prune:
	@repo="$$(basename "$(CURDIR)")"; \
	prune_in() { find "$$1" $$2 -type l \( -lname "$$repo/*" -o -lname "*/$$repo/*" \) ! -exec test -e {} \; -print -exec rm -- {} + ; }; \
	prune_in "$(HOME)" "-maxdepth 1"; \
	for dir in $$(git ls-files | grep / | cut -d/ -f1 | sort -u); do \
		[ -d "$(HOME)/$$dir" ] && prune_in "$(HOME)/$$dir" ""; \
	done; \
	true

desktop:
	@scripts/setup-gnome-desktop.sh

font:
	@scripts/setup-font.sh
