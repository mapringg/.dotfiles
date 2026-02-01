.DEFAULT_GOAL := help

SHELL := /bin/sh

UNAME_S := $(shell uname -s 2>/dev/null)
ifeq ($(UNAME_S),Darwin)
    OS := mac
else
    OS := linux
endif

BREW := $(shell command -v brew 2>/dev/null)
STOW := $(shell command -v stow 2>/dev/null)
MISE := $(shell command -v mise 2>/dev/null)
ANTIDOTE := $(shell command -v antidote 2>/dev/null || (command -v brew >/dev/null 2>&1 && brew --prefix 2>/dev/null | xargs -I{} printf "%s\n" "{}/opt/antidote/share/antidote/antidote.zsh"))

.PHONY: help
help:
	@printf "%s\n" "Targets:" \
		"  make doctor        Check system prerequisites" \
		"  make deps          Install OS packages" \
		"  make link          Symlink dotfiles into $$HOME (stow)" \
		"  make tools         Install mise tools" \
		"  make tmux          Install tmux TPM plugins" \
		"  make zsh           Install zsh plugins (antidote)" \
		"  make setup         deps + link + tools + tmux + zsh" \
		"" \
		"Notes:" \
		"  - mac: uses Homebrew + packages/brew/Brewfile" \
		"  - linux: Arch only (pacman + yay)" \
		"  - stow: links this repo into your home directory"

.PHONY: doctor
doctor:
	@printf "%s\n" "OS: $(OS)" "Repo: $$(pwd)" "Home: $$HOME"
	@if [ -z "$(STOW)" ]; then printf "%s\n" "Missing: stow"; exit 1; fi
	@if [ "$(OS)" = "mac" ] && [ -z "$(BREW)" ]; then printf "%s\n" "Missing: brew"; exit 1; fi
	@if [ -z "$(MISE)" ]; then printf "%s\n" "Missing: mise"; exit 1; fi
	@if [ -z "$(ANTIDOTE)" ] || [ ! -f "$(ANTIDOTE)" ]; then printf "%s\n" "Missing: antidote"; exit 1; fi
	@printf "%s\n" "OK: prerequisites present"

.PHONY: deps
deps:
	@if [ "$(OS)" = "mac" ]; then \
		$(MAKE) deps-mac; \
	else \
		$(MAKE) deps-linux; \
	fi

.PHONY: deps-mac
deps-mac:
	@if [ -z "$(BREW)" ]; then printf "%s\n" "brew not found. Install Homebrew first:" "  https://brew.sh"; exit 1; fi
	@if [ ! -f packages/brew/Brewfile ]; then printf "%s\n" "Missing Brewfile"; exit 1; fi
	@brew bundle --file packages/brew/Brewfile

.PHONY: deps-linux
deps-linux:
	@if ! command -v pacman >/dev/null 2>&1; then printf "%s\n" "Missing: pacman"; exit 1; fi
	@if ! command -v yay >/dev/null 2>&1; then printf "%s\n" "Missing: yay"; exit 1; fi
	@if [ ! -f packages/arch/pacman.txt ]; then printf "%s\n" "Missing: packages/arch/pacman.txt"; exit 1; fi
	@if [ ! -f packages/arch/aur.txt ]; then printf "%s\n" "Missing: packages/arch/aur.txt"; exit 1; fi
	@xargs -a packages/arch/pacman.txt sudo pacman -S --needed --noconfirm
	@xargs -a packages/arch/aur.txt yay -S --needed --noconfirm

.PHONY: link
link:
	@if [ -z "$(STOW)" ]; then printf "%s\n" "stow not found"; exit 1; fi
	@stow --no-folding --target="$$HOME" --restow --verbose=1 .

.PHONY: tools
tools:
	@if [ -z "$(MISE)" ]; then \
		printf "%s\n" "Missing: mise"; \
		exit 1; \
	fi
	@if [ -f .config/mise/config.toml ]; then \
		mise install; \
	else \
		printf "%s\n" "Missing: .config/mise/config.toml"; \
		exit 1; \
	fi

.PHONY: zsh
zsh:
	@if [ ! -f "$$HOME/.zsh_plugins.txt" ]; then \
		printf "%s\n" "Missing: $$HOME/.zsh_plugins.txt"; \
		exit 1; \
	fi
	@if [ -z "$(ANTIDOTE)" ] || [ ! -f "$(ANTIDOTE)" ]; then \
		printf "%s\n" "Missing: antidote"; \
		exit 1; \
	fi
	@zsh -c 'source "$(ANTIDOTE)" && antidote update'
	@zsh -c 'source "$(ANTIDOTE)" && antidote bundle < "$$HOME/.zsh_plugins.txt" > "$$HOME/.zsh_plugins.zsh"'

.PHONY: tmux
tmux:
	@if [ ! -d "$$HOME/.config/tmux/plugins/tpm" ]; then \
		git clone https://github.com/tmux-plugins/tpm "$$HOME/.config/tmux/plugins/tpm"; \
	fi
	@"$$HOME/.config/tmux/plugins/tpm/bin/install_plugins"

.PHONY: setup
setup: deps link tools tmux zsh
