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

.PHONY: help
help:
	@printf "%s\n" "Targets:" \
		"  make doctor        Check system prerequisites" \
		"  make deps          Install OS packages (brew/apt)" \
		"  make link          Symlink dotfiles into $$HOME (stow)" \
		"  make tools         Install mise tools (if configured)" \
		"  make setup         deps + link + tools" \
		"" \
		"Notes:" \
		"  - mac: uses Homebrew + Brewfile" \
		"  - linux: placeholder (we'll add pacman/AUR later)" \
		"  - stow: links this repo into your home directory"

.PHONY: doctor
doctor:
	@printf "%s\n" "OS: $(OS)" "Repo: $$(pwd)" "Home: $$HOME"
	@if [ -z "$(STOW)" ]; then printf "%s\n" "Missing: stow"; exit 1; fi
	@if [ "$(OS)" = "mac" ] && [ -z "$(BREW)" ]; then printf "%s\n" "Missing: brew"; exit 1; fi
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
	@if [ ! -f Brewfile ]; then printf "%s\n" "Missing Brewfile"; exit 1; fi
	@brew bundle --file Brewfile

.PHONY: deps-linux
deps-linux:
	@if ! command -v pacman >/dev/null 2>&1; then printf "%s\n" "Missing: pacman"; exit 1; fi
	@if ! command -v yay >/dev/null 2>&1; then printf "%s\n" "Missing: yay"; exit 1; fi
	@if [ ! -f packages/arch/pacman.txt ]; then printf "%s\n" "Missing: packages/arch/pacman.txt"; exit 1; fi
	@if [ ! -f packages/arch/aur.txt ]; then printf "%s\n" "Missing: packages/arch/aur.txt"; exit 1; fi
	@sudo pacman -S --needed - < packages/arch/pacman.txt
	@yay -S --needed - < packages/arch/aur.txt

.PHONY: link
link:
	@if [ -z "$(STOW)" ]; then printf "%s\n" "stow not found"; exit 1; fi
	@stow --no-folding --target="$$HOME" --restow --verbose=1 .

.PHONY: tools
tools:
	@if [ -z "$(MISE)" ]; then \
		printf "%s\n" "mise not found; skipping tool install."; \
		exit 0; \
	fi
	@if [ -f .config/mise/config.toml ]; then \
		mise install; \
	else \
		printf "%s\n" "No mise config found; skipping."; \
	fi

.PHONY: setup
setup: deps link tools
