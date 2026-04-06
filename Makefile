SHELL := /bin/bash
PATH := $(HOME)/.local/bin:$(PATH)
UNAME_S := $(shell uname -s)
ARCH_PACKAGES := fd fzf github-cli git jq ripgrep stow wl-clipboard zoxide zsh zsh-autosuggestions zsh-syntax-highlighting

.PHONY: setup setup-common setup-macos setup-arch install-macos-packages install-arch-packages install-mise install-starship install-claude install-amp

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
	stow --no-folding --target="$$HOME" --restow --verbose=1 .
	mise install
	$(MAKE) install-claude
	$(MAKE) install-amp

setup-macos: install-macos-packages install-mise install-starship setup-common

install-macos-packages:
	brew bundle --file Brewfile

setup-arch: install-arch-packages install-mise install-starship setup-common

install-arch-packages:
	sudo pacman -S --needed --noconfirm $(ARCH_PACKAGES)

install-mise:
	@if command -v mise >/dev/null 2>&1; then \
		echo "mise already installed"; \
	else \
		curl https://mise.run | sh; \
	fi

install-starship:
	@if command -v starship >/dev/null 2>&1; then \
		echo "starship already installed"; \
	else \
		curl -sS https://starship.rs/install.sh | sh -s -- -y; \
	fi

install-claude:
	@if command -v claude >/dev/null 2>&1; then \
		echo "claude already installed"; \
	else \
		curl -fsSL https://claude.ai/install.sh | bash; \
	fi

install-amp:
	@if command -v amp >/dev/null 2>&1; then \
		echo "amp already installed"; \
	else \
		curl -fsSL https://ampcode.com/install.sh | bash; \
	fi
