SHELL := /bin/bash
PATH := $(HOME)/.local/bin:$(PATH)
UNAME_S := $(shell uname -s)
ARCH_PACKAGES := biome fd fzf github-cli git jq ripgrep stow tmux wl-clipboard zoxide zsh zsh-autosuggestions zsh-syntax-highlighting

.PHONY: setup setup-common setup-macos setup-arch install-macos-packages install-arch-packages install-claude install-amp install-tpm

setup:
ifeq ($(UNAME_S),Darwin)
	$(MAKE) setup-macos
else ifeq ($(UNAME_S),Linux)
	$(MAKE) setup-arch
else
	@echo "Unsupported OS: $(UNAME_S)" >&2
	@exit 1
endif

setup-common:
	stow --no-folding --target="$(HOME)" --restow --verbose=1 .
	mise install
	$(MAKE) install-claude
	$(MAKE) install-amp
	$(MAKE) install-tpm

setup-macos: install-macos-packages setup-common

install-macos-packages:
	brew bundle --file Brewfile

setup-arch: install-arch-packages setup-common

install-arch-packages:
	sudo pacman -S --needed --noconfirm $(ARCH_PACKAGES)

define install-tool
@if command -v $(1) >/dev/null 2>&1; then \
	echo "$(1) already installed"; \
else \
	curl -fsSL $(2) | bash; \
fi
endef

install-claude:
	$(call install-tool,claude,https://claude.ai/install.sh)

install-amp:
	$(call install-tool,amp,https://ampcode.com/install.sh)

install-tpm:
	@if [ -d "$(HOME)/.config/tmux/plugins/tpm" ]; then \
		echo "tpm already installed"; \
	else \
		git clone --depth 1 https://github.com/tmux-plugins/tpm "$(HOME)/.config/tmux/plugins/tpm"; \
	fi
