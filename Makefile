.DEFAULT_GOAL := help
SHELL := /bin/sh

ANTIDOTE := $(shell command -v brew >/dev/null 2>&1 && brew --prefix 2>/dev/null | xargs -I{} printf "%s" "{}/opt/antidote/share/antidote/antidote.zsh")
BREW := $(shell command -v brew 2>/dev/null)
MISE := $(shell command -v mise 2>/dev/null)
STOW := $(shell command -v stow 2>/dev/null)

define require
	@[ -n "$(2)" ] || { printf "Missing: %s\n" "$(1)"; exit 1; }
endef

define require_file
	@[ -f "$(1)" ] || { printf "Missing: %s\n" "$(1)"; exit 1; }
endef

.PHONY: help doctor deps link setup tmux tools zsh

help:
	@printf "%s\n" \
		"  deps     Install brew packages" \
		"  doctor   Check prerequisites" \
		"  link     Symlink dotfiles (stow)" \
		"  setup    deps + link + tools + tmux + zsh" \
		"  tmux     Install TPM plugins" \
		"  tools    Install mise tools" \
		"  zsh      Install zsh plugins"

doctor:
	@printf "%s\n" "Repo: $$(pwd)" "Home: $$HOME"
	$(call require,stow,$(STOW))
	$(call require,mise,$(MISE))
	$(call require,brew,$(BREW))
	@[ -f "$(ANTIDOTE)" ] || { printf "Missing: antidote\n"; exit 1; }
	@printf "OK\n"

deps:
	$(call require,brew,$(BREW))
	$(call require_file,Brewfile)
	@brew bundle --file Brewfile

link:
	$(call require,stow,$(STOW))
	@stow --no-folding --target="$$HOME" --restow --verbose=1 .

setup: deps link tools tmux zsh

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
