.DEFAULT_GOAL := help
SHELL := /bin/sh

UNAME_S := $(shell uname -s 2>/dev/null)
ifeq ($(UNAME_S),Darwin)
    OS := mac
else
    OS := linux
endif

ANTIDOTE := $(shell command -v antidote 2>/dev/null || ([ -f /usr/share/zsh-antidote/antidote.zsh ] && printf "%s" "/usr/share/zsh-antidote/antidote.zsh") || (command -v brew >/dev/null 2>&1 && brew --prefix 2>/dev/null | xargs -I{} printf "%s" "{}/opt/antidote/share/antidote/antidote.zsh"))
BREW := $(shell command -v brew 2>/dev/null)
MISE := $(shell command -v mise 2>/dev/null)
STOW := $(shell command -v stow 2>/dev/null)

define require
	@[ -n "$(2)" ] || { printf "Missing: %s\n" "$(1)"; exit 1; }
endef

define require_file
	@[ -f "$(1)" ] || { printf "Missing: %s\n" "$(1)"; exit 1; }
endef

.PHONY: help doctor deps deps-linux deps-mac link local setup tmux tools zsh

help:
	@printf "%s\n" \
		"  deps     Install OS packages" \
		"  doctor   Check prerequisites" \
		"  link     Symlink dotfiles (stow)" \
		"  local    Create local.zsh if missing" \
		"  setup    deps + link + tools + tmux + zsh + local" \
		"  tmux     Install TPM plugins" \
		"  tools    Install mise tools" \
		"  zsh      Install zsh plugins"

doctor:
	@printf "%s\n" "OS: $(OS)" "Repo: $$(pwd)" "Home: $$HOME"
	$(call require,stow,$(STOW))
	$(call require,mise,$(MISE))
	@[ -f "$(ANTIDOTE)" ] || { printf "Missing: antidote\n"; exit 1; }
	@[ "$(OS)" != "mac" ] || [ -n "$(BREW)" ] || { printf "Missing: brew\n"; exit 1; }
	@printf "OK\n"

deps:
	@$(MAKE) --no-print-directory deps-$(OS)

deps-linux:
	@command -v pacman >/dev/null || { printf "Missing: pacman\n"; exit 1; }
	@command -v yay >/dev/null || { printf "Missing: yay\n"; exit 1; }
	$(call require_file,packages/arch/pacman.txt)
	$(call require_file,packages/arch/aur.txt)
	@xargs -a packages/arch/pacman.txt sudo pacman -S --needed --noconfirm
	@xargs -a packages/arch/aur.txt yay -S --needed --noconfirm

deps-mac:
	$(call require,brew,$(BREW))
	$(call require_file,packages/brew/Brewfile)
	@brew bundle --file packages/brew/Brewfile

link:
	$(call require,stow,$(STOW))
	@stow --no-folding --target="$$HOME" --restow --verbose=1 .

local:
	@[ -f "$$HOME/.config/zsh/local.zsh" ] || { mkdir -p "$$HOME/.config/zsh" && touch "$$HOME/.config/zsh/local.zsh"; }

setup: deps link tools tmux zsh local

tmux:
	@[ -d "$$HOME/.config/tmux/plugins/tpm" ] || git clone https://github.com/tmux-plugins/tpm "$$HOME/.config/tmux/plugins/tpm"
	@"$$HOME/.config/tmux/plugins/tpm/bin/install_plugins"

tools:
	$(call require,mise,$(MISE))
	$(call require_file,.config/mise/config.toml)
	@mise install

zsh:
	$(call require_file,$$HOME/.zsh_plugins.txt)
	@[ -f "$(ANTIDOTE)" ] || { printf "Missing: antidote\n"; exit 1; }
	@zsh -c 'source "$(ANTIDOTE)" && antidote update'
	@zsh -c 'source "$(ANTIDOTE)" && antidote bundle < "$$HOME/.zsh_plugins.txt" > "$$HOME/.zsh_plugins.zsh"'
