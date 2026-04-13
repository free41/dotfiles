# Dotfiles Makefile
# Manages symlinks between dotfiles repo and system locations

SHELL := /bin/bash
.SHELLFLAGS := -o pipefail -c

# Default variables
DOTFILES_DIR := $(shell pwd)
VSCODE_DIR := $(DOTFILES_DIR)/vscode
OBSIDIAN_DIR := $(DOTFILES_DIR)/obsidian
CODE_BIN := code
GIT_USER_NAME := your-git-username
GIT_USER_EMAIL := your-email@example.com
OBSIDIAN_VAULT_PATH := ~/Vault

# Include machine-specific config if it exists
-include config.mk

.PHONY: all help install install-server _apt-setup stow unstow stow-adopt stow-bash stow-git stow-vim stow-nvim stow-tmux unstow-bash unstow-git unstow-vim unstow-nvim unstow-tmux vscode-fetch vscode-push obsidian-fetch obsidian-push

# Package lists
PACKAGES_BASE   := stow git tmux curl build-essential ripgrep tree fzf make
PACKAGES_DESKTOP := neovim xclip

# Default target
.DEFAULT_GOAL := all

_apt-setup:
	@echo ""
	@echo "╔════════════════════════════════════════════════════════════════════════════╗"
	@echo "║                      Installing required dependencies                      ║"
	@echo "╚════════════════════════════════════════════════════════════════════════════╝"
	@echo ""
	@if grep -qi 'ID=ubuntu' /etc/os-release 2>/dev/null; then \
		echo "→ Ubuntu detected: adding neovim PPA (latest stable builds)..."; \
		sudo add-apt-repository -y ppa:neovim-ppa/unstable 2>&1 | sed 's/^/  /'; \
		echo ""; \
	else \
		echo "→ Debian/PiOS detected: skipping Ubuntu PPA, using distro packages..."; \
		echo ""; \
	fi
	@echo "→ Updating package lists..."
	@sudo apt update 2>&1 | sed 's/^/  /'
	@echo ""

_apt-done:
	@echo ""
	@echo "╔════════════════════════════════════════════════════════════════════════════╗"
	@echo "║                        ✓ All dependencies installed!                       ║"
	@echo "╚════════════════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "┌─ Optional Installations ───────────────────────────────────────────────────┐"
	@echo "│                                                                            │"
	@echo "│  uv (Python package and tool manager):                                     │"
	@echo "│    curl -LsSf https://astral.sh/uv/install.sh | sh                         │"
	@echo "│                                                                            │"
	@echo "│  tailscale                                                                 │"
	@echo "│    curl -fsSL https://tailscale.com/install.sh | sh                        │"
	@echo "│                                                                            │"
	@echo "└────────────────────────────────────────────────────────────────────────────┘"
	@echo ""
	@echo "┌─ Next Steps ───────────────────────────────────────────────────────────────┐"
	@echo "│                                                                            │"
	@echo "│  1. Import SSH keys from GitHub:                                           │"
	@echo "│       ssh-import-id gh:<github-username>                                   │"
	@echo "│                                                                            │"
	@echo "│  2. Run 'make all' to setup dotfiles                                       │"
	@echo "│  3. Restart your shell or run 'source ~/.bashrc'                           │"
	@echo "│                                                                            │"
	@echo "└────────────────────────────────────────────────────────────────────────────┘"

install: _apt-setup
	@echo "→ Installing packages..."
	@sudo apt install -y $(PACKAGES_BASE) $(PACKAGES_DESKTOP) 2>&1 | sed 's/^/  /'
	@echo ""
	@echo "→ Checking neovim version..."
	@if command -v nvim >/dev/null 2>&1; then \
		NVIM_VERSION=$$(nvim --version | head -1 | sed 's/NVIM v//'); \
		echo "  ✓ Neovim $$NVIM_VERSION is installed"; \
	else \
		echo "  ⚠ Neovim not found (was just installed above, try restarting shell)"; \
	fi
	@$(MAKE) --no-print-directory _apt-done

install-server: _apt-setup
	@echo "→ Installing packages (server, no neovim)..."
	@sudo apt install -y $(PACKAGES_BASE) vim 2>&1 | sed 's/^/  /'
	@$(MAKE) --no-print-directory _apt-done
	@echo ""

all:
	@echo ""
	@echo "╔════════════════════════════════════════════════════════════════════════════╗"
	@echo "║                         Setting up dotfiles                                ║"
	@echo "╚════════════════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "→ Initializing git submodules..."
	@git submodule update --init --recursive 2>&1 | sed 's/^/  /'
	@echo ""
	@echo "→ Installing packages..."
	@echo ""
	@if $(MAKE) --no-print-directory stow 2>/dev/null; then \
		echo ""; \
		echo "╔════════════════════════════════════════════════════════════════════════════╗"; \
		echo "║                           ✓ Setup Complete!                                ║"; \
		echo "╚════════════════════════════════════════════════════════════════════════════╝"; \
	else \
		echo ""; \
		echo "╔════════════════════════════════════════════════════════════════════════════╗"; \
		echo "║                            ⚠ Setup Failed                                  ║"; \
		echo "╚════════════════════════════════════════════════════════════════════════════╝"; \
		echo ""; \
		echo "  Stow failed! This usually happens when files already exist."; \
		echo "  Run 'make stow-adopt' to merge existing files into the repo."; \
		exit 1; \
	fi
	@echo ""
	@echo "┌─ Optional Commands ────────────────────────────────────────────────────────┐"
	@echo "│                                                                            │"
	@echo "│  VSCode Sync (WSL only):                                                   │"
	@echo "│    make vscode-fetch    Copy VSCode config from Windows to repo            │"
	@echo "│    make vscode-push     Copy VSCode config from repo to Windows            │"
	@echo "│                                                                            │"
	@echo "│  Obsidian Vault Sync:                                                      │"
	@echo "│    make obsidian-fetch  Copy .obsidian settings from vault to repo         │"
	@echo "│    make obsidian-push   Copy .obsidian settings from repo to vault         │"
	@echo "│                                                                            │"
	@echo "└────────────────────────────────────────────────────────────────────────────┘"
	@echo ""

help:
	@echo "Available targets:"
	@echo "  install                   - Install all dependencies including neovim"
	@echo "  install-server            - Install dependencies without neovim (uses vim)"
	@echo "  all                       - Setup dotfiles (stow all packages + install plugins)"
	@echo "  stow                      - Stow all packages (bash, git, nvim, vim, tmux)"
	@echo "  stow-adopt                - Stow with --adopt (replaces repo files with existing ones)"
	@echo "  unstow                    - Unstow all packages"
	@echo "  stow-bash                 - Stow bash configuration"
	@echo "  stow-git                  - Stow git configuration"
	@echo "  stow-nvim                 - Stow neovim config and sync lazy.nvim plugins"
	@echo "  stow-vim                  - Stow vim configuration and auto-install plugins"
	@echo "  stow-tmux                 - Stow tmux configuration"
	@echo "  unstow-bash               - Unstow bash configuration"
	@echo "  unstow-git                - Unstow git configuration"
	@echo "  unstow-nvim               - Unstow neovim configuration"
	@echo "  unstow-vim                - Unstow vim configuration"
	@echo "  unstow-tmux               - Unstow tmux configuration"
	@echo "  vscode-fetch              - Copy VSCode config from Windows to repo (WSL only)"
	@echo "  vscode-push               - Copy VSCode config from repo to Windows (WSL only)"
	@echo "  obsidian-fetch            - Copy .obsidian, templates, scripts from vault to repo (existing files only)"
	@echo "  obsidian-push             - Copy .obsidian, templates, scripts from repo to vault"

# Stow targets
stow: stow-bash stow-git stow-nvim stow-vim stow-tmux

stow-adopt:
	@echo "Adopting existing files and stowing..."
	@stow -d $(DOTFILES_DIR) -t ~ --adopt bash git vim tmux
	@mkdir -p ~/.config
	@stow -d $(DOTFILES_DIR) -t ~/.config --adopt nvim
	@echo ""
	@echo "✓ All packages stowed with --adopt!"
	@echo ""
	@echo "⚠ Important: Check what changed in the repo:"
	@echo "  git diff"
	@echo ""
	@echo "  To keep repo version: git restore ."
	@echo "  To keep adopted version: git add . && git commit"

unstow: unstow-bash unstow-git unstow-nvim unstow-vim unstow-tmux
	@echo "✓ All packages unstowed successfully!"

stow-bash:
	@printf "  %-20s" "bash"
	@stow -d $(DOTFILES_DIR) -t ~ bash 2>&1 | sed 's/^/    /' || exit 1
	@if [ -n "$$BASH_VERSION" ]; then \
		bash -c "source ~/.bashrc" && echo "✓"; \
	else \
		echo "✓"; \
	fi

stow-git:
	@printf "  %-20s" "git"
	@sed 's/@GIT_USER_NAME@/$(GIT_USER_NAME)/g; s/@GIT_USER_EMAIL@/$(GIT_USER_EMAIL)/g' \
		$(DOTFILES_DIR)/git/.gitconfig.template > $(DOTFILES_DIR)/git/.gitconfig 2>&1 | sed 's/^/    /' || exit 1
	@stow -d $(DOTFILES_DIR) -t ~ git 2>&1 | sed 's/^/    /' || exit 1
	@echo "✓"

stow-vim:
	@printf "  %-20s" "vim"
	@stow -d $(DOTFILES_DIR) -t ~ vim 2>&1 | sed 's/^/    /' || exit 1
	@rm -rf ~/.vim/plugged ~/.vim/autoload
	@echo "✓"

stow-nvim:
	@printf "  %-20s" "nvim"
	@mkdir -p ~/.config
	@stow -d $(DOTFILES_DIR) -t ~/.config nvim 2>&1 | sed 's/^/    /' || exit 1
	@if command -v nvim >/dev/null 2>&1; then \
		nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 && echo "✓" || echo "⚠ (lazy.nvim sync failed, run :Lazy sync manually)"; \
	else \
		echo "⚠ (nvim not found, install with: sudo apt install neovim)"; \
	fi

stow-tmux:
	@printf "  %-20s" "tmux"
	@stow -d $(DOTFILES_DIR) -t ~ tmux 2>&1 | sed 's/^/    /' || exit 1
	@echo "✓"

unstow-bash:
	@echo "Unstowing bash..."
	@stow -d $(DOTFILES_DIR) -t ~ -D bash

unstow-git:
	@echo "Unstowing git..."
	@stow -d $(DOTFILES_DIR) -t ~ -D git
	@rm -f $(DOTFILES_DIR)/git/.gitconfig
	@echo "Removed generated .gitconfig"

unstow-vim:
	@echo "Unstowing vim..."
	@stow -d $(DOTFILES_DIR) -t ~ -D vim

unstow-nvim:
	@echo "Unstowing nvim..."
	@stow -d $(DOTFILES_DIR) -t ~/.config -D nvim

unstow-tmux:
	@echo "Unstowing tmux..."
	@stow -d $(DOTFILES_DIR) -t ~ -D tmux

# VSCode targets
vscode-fetch:
	@echo ""
	@echo "┌─ VSCode Fetch ───────────────────────────────────────────────────────────────┐"
	@mkdir -p $(VSCODE_DIR)
	@if [ -f "$(VSCODE_WIN_USER)/settings.json" ]; then \
		cp "$(VSCODE_WIN_USER)/settings.json" "$(VSCODE_DIR)/settings.json"; \
		echo "│  ✓ settings.json"; \
	else \
		echo "│  ⚠ settings.json not found"; \
	fi
	@if [ -f "$(VSCODE_WIN_USER)/keybindings.json" ]; then \
		cp "$(VSCODE_WIN_USER)/keybindings.json" "$(VSCODE_DIR)/keybindings.json"; \
		echo "│  ✓ keybindings.json"; \
	else \
		echo "│  ⚠ keybindings.json not found"; \
	fi
	@cmd.exe /c "code --list-extensions" 2>/dev/null | sed 's/\r$$//' > $(VSCODE_DIR)/extensions.txt
	@echo "│  ✓ extensions.txt ($(shell wc -l < $(VSCODE_DIR)/extensions.txt 2>/dev/null || echo 0) extensions)"
	@echo "└──────────────────────────────────────────────────────────────────────────────┘"
	@echo ""

vscode-push:
	@echo ""
	@echo "┌─ VSCode Push ────────────────────────────────────────────────────────────────┐"
	@if [ -f "$(VSCODE_DIR)/settings.json" ]; then \
		cp "$(VSCODE_DIR)/settings.json" "$(VSCODE_WIN_USER)/settings.json"; \
		echo "│  ✓ settings.json"; \
	else \
		echo "│  ⚠ settings.json not found"; \
	fi
	@if [ -f "$(VSCODE_DIR)/keybindings.json" ]; then \
		cp "$(VSCODE_DIR)/keybindings.json" "$(VSCODE_WIN_USER)/keybindings.json"; \
		echo "│  ✓ keybindings.json"; \
	else \
		echo "│  ⚠ keybindings.json not found"; \
	fi
	@if [ ! -f "$(VSCODE_DIR)/extensions.txt" ]; then \
		echo "│  ⚠ extensions.txt not found"; \
	else \
		echo "│  → Installing $(shell wc -l < $(VSCODE_DIR)/extensions.txt) extensions..."; \
		for ext in $$(cat $(VSCODE_DIR)/extensions.txt); do \
			cmd.exe /c "code --install-extension $$ext" 2>/dev/null | sed 's/\r$$//' || true; \
		done; \
		echo "│  ✓ Extensions installed"; \
	fi
	@echo "└──────────────────────────────────────────────────────────────────────────────┘"
	@echo ""

# Obsidian targets
obsidian-fetch:
	@echo ""
	@echo "┌─ Obsidian Fetch ─────────────────────────────────────────────────────────────┐"
	@if [ ! -d "$(OBSIDIAN_VAULT_PATH)" ]; then \
		echo "│  ⚠ Vault not found at $(OBSIDIAN_VAULT_PATH)"; \
		echo "│  Set OBSIDIAN_VAULT_PATH in config.mk"; \
		echo "└──────────────────────────────────────────────────────────────────────────────┘"; \
		exit 1; \
	fi
	@mkdir -p $(OBSIDIAN_DIR)/.obsidian $(OBSIDIAN_DIR)/templates
	@COPIED=0; \
	if [ -d "$(OBSIDIAN_DIR)/.obsidian" ]; then \
		for file in $$(cd $(OBSIDIAN_DIR)/.obsidian && find . -type f); do \
			relpath=$${file#./}; \
			if [ -f "$(OBSIDIAN_VAULT_PATH)/.obsidian/$$relpath" ]; then \
				mkdir -p "$$(dirname "$(OBSIDIAN_DIR)/.obsidian/$$relpath")"; \
				cp "$(OBSIDIAN_VAULT_PATH)/.obsidian/$$relpath" "$(OBSIDIAN_DIR)/.obsidian/$$relpath"; \
				echo "│  ✓ .obsidian/$$relpath"; \
				COPIED=$$((COPIED + 1)); \
			else \
				echo "│  ⚠ .obsidian/$$relpath not found in vault"; \
			fi; \
		done; \
	fi; \
	if [ $$COPIED -eq 0 ]; then \
		echo "│  ⚠ No .obsidian files copied (add files to $(OBSIDIAN_DIR)/.obsidian first)"; \
	fi
	@COPIED=0; \
	if [ -d "$(OBSIDIAN_VAULT_PATH)/templates" ]; then \
		for file in $(OBSIDIAN_DIR)/templates/*; do \
			if [ -f "$$file" ]; then \
				filename=$$(basename "$$file"); \
				if [ -f "$(OBSIDIAN_VAULT_PATH)/templates/$$filename" ]; then \
					cp "$(OBSIDIAN_VAULT_PATH)/templates/$$filename" "$(OBSIDIAN_DIR)/templates/$$filename"; \
					echo "│  ✓ templates/$$filename"; \
					COPIED=$$((COPIED + 1)); \
				else \
					echo "│  ⚠ templates/$$filename not found in vault"; \
				fi; \
			fi; \
		done; \
	else \
		echo "│  ⚠ templates folder not found in vault"; \
	fi; \
	if [ $$COPIED -eq 0 ]; then \
		echo "│  ⚠ No template files copied"; \
	fi
	@mkdir -p $(OBSIDIAN_DIR)/scripts
	@COPIED=0; \
	if [ -d "$(OBSIDIAN_VAULT_PATH)/scripts" ]; then \
		for file in $(OBSIDIAN_DIR)/scripts/*; do \
			if [ -f "$$file" ]; then \
				filename=$$(basename "$$file"); \
				if [ -f "$(OBSIDIAN_VAULT_PATH)/scripts/$$filename" ]; then \
					cp "$(OBSIDIAN_VAULT_PATH)/scripts/$$filename" "$(OBSIDIAN_DIR)/scripts/$$filename"; \
					echo "│  ✓ scripts/$$filename"; \
					COPIED=$$((COPIED + 1)); \
				else \
					echo "│  ⚠ scripts/$$filename not found in vault"; \
				fi; \
			fi; \
		done; \
	else \
		echo "│  ⚠ scripts folder not found in vault"; \
	fi; \
	if [ $$COPIED -eq 0 ]; then \
		echo "│  ⚠ No script files copied (add files to $(OBSIDIAN_DIR)/scripts first)"; \
	fi
	@echo "└──────────────────────────────────────────────────────────────────────────────┘"
	@echo ""

obsidian-push:
	@echo ""
	@echo "┌─ Obsidian Push ──────────────────────────────────────────────────────────────┐"
	@if [ ! -d "$(OBSIDIAN_VAULT_PATH)" ]; then \
		echo "│  ⚠ Vault not found at $(OBSIDIAN_VAULT_PATH)"; \
		echo "│  Set OBSIDIAN_VAULT_PATH in config.mk"; \
		echo "└──────────────────────────────────────────────────────────────────────────────┘"; \
		exit 1; \
	fi
	@mkdir -p "$(OBSIDIAN_VAULT_PATH)/.obsidian"
	@COPIED=0; \
	if [ -d "$(OBSIDIAN_DIR)/.obsidian" ]; then \
		for file in $$(cd $(OBSIDIAN_DIR)/.obsidian && find . -type f); do \
			relpath=$${file#./}; \
			mkdir -p "$$(dirname "$(OBSIDIAN_VAULT_PATH)/.obsidian/$$relpath")"; \
			cp "$(OBSIDIAN_DIR)/.obsidian/$$relpath" "$(OBSIDIAN_VAULT_PATH)/.obsidian/$$relpath"; \
			echo "│  ✓ .obsidian/$$relpath"; \
			COPIED=$$((COPIED + 1)); \
		done; \
	fi; \
	if [ $$COPIED -eq 0 ]; then \
		echo "│  ⚠ No .obsidian files to push"; \
	fi
	@mkdir -p "$(OBSIDIAN_VAULT_PATH)/templates"
	@COPIED=0; \
	for file in $(OBSIDIAN_DIR)/templates/*; do \
		if [ -f "$$file" ]; then \
			filename=$$(basename "$$file"); \
			cp "$$file" "$(OBSIDIAN_VAULT_PATH)/templates/$$filename"; \
			echo "│  ✓ templates/$$filename"; \
			COPIED=$$((COPIED + 1)); \
		fi; \
	done; \
	if [ $$COPIED -eq 0 ]; then \
		echo "│  ⚠ No template files to push"; \
	fi
	@mkdir -p "$(OBSIDIAN_VAULT_PATH)/scripts"
	@COPIED=0; \
	for file in $(OBSIDIAN_DIR)/scripts/*; do \
		if [ -f "$$file" ]; then \
			filename=$$(basename "$$file"); \
			cp "$$file" "$(OBSIDIAN_VAULT_PATH)/scripts/$$filename"; \
			echo "│  ✓ scripts/$$filename"; \
			COPIED=$$((COPIED + 1)); \
		fi; \
	done; \
	if [ $$COPIED -eq 0 ]; then \
		echo "│  ⚠ No script files to push"; \
	fi
	@echo "└──────────────────────────────────────────────────────────────────────────────┘"
	@echo ""
