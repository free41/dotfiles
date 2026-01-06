# Dotfiles Makefile
# Manages symlinks between dotfiles repo and system locations

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

.PHONY: all help install stow unstow stow-adopt stow-bash stow-git stow-vim stow-tmux unstow-bash unstow-git unstow-vim unstow-tmux vscode-fetch vscode-push obsidian-fetch obsidian-push

# Default target
.DEFAULT_GOAL := all

install:
	@echo "========================================="
	@echo "Installing required dependencies..."
	@echo "========================================="
	@echo ""
	@echo "Updating package lists..."
	@sudo apt update
	@echo ""
	@echo "Installing core packages..."
	@sudo apt install -y \
		stow \
		git \
		tmux \
		vim-gtk3 \
		curl \
		build-essential \
		universal-ctags \
		ripgrep \
		tree \
		xclip
	@echo ""
	@echo "========================================="
	@echo "✓ All dependencies installed!"
	@echo "========================================="
	@echo ""
	@echo "Checking Node.js installation..."
	@if command -v node >/dev/null 2>&1; then \
		NODE_VERSION=$$(node -v | sed 's/v//'); \
		NODE_MAJOR=$$(echo $$NODE_VERSION | cut -d. -f1); \
		NODE_MINOR=$$(echo $$NODE_VERSION | cut -d. -f2); \
		if [ $$NODE_MAJOR -gt 14 ] || ([ $$NODE_MAJOR -eq 14 ] && [ $$NODE_MINOR -ge 14 ]); then \
			echo "✓ Node.js $$NODE_VERSION is installed (coc.nvim requires >= 14.14)"; \
		else \
			echo "⚠ Node.js $$NODE_VERSION is installed but coc.nvim requires >= 14.14"; \
			echo "  Please upgrade Node.js"; \
		fi; \
	else \
		echo "⚠ Node.js not found!"; \
		echo ""; \
		echo "  coc.nvim (LSP support) requires Node.js >= 14.14"; \
		echo ""; \
		echo "  Install Node.js via nvm (Node Version Manager):"; \
		echo "    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"; \
		echo "    source ~/.bashrc"; \
		echo "    nvm install --lts"; \
		echo "    nvm use --lts"; \
		echo ""; \
		echo "  Or skip it - vim will work without LSP features."; \
	fi
	@echo ""
	@echo "ℹ Optional: Install code-minimap for minimap.vim"
	@echo "  The minimap plugin requires code-minimap, which needs Rust."
	@echo "  To install:"
	@echo "    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
	@echo "    source ~/.cargo/env"
	@echo "    cargo install --locked code-minimap"
	@echo "  Or skip it - minimap.vim will be disabled if not found."
	@echo ""
	@echo "ℹ Optional: Install uv (Python package and tool manager)"
	@echo "  To install:"
	@echo "    curl -LsSf https://astral.sh/uv/install.sh | sh"
	@echo "    source ~/.bashrc"
	@echo "  Or skip it - Python tools will work without uv."
	@echo ""
	@echo "ℹ Optional: Install Marksman for Markdown LSP support"
	@echo "  To install:"
	@echo "    sudo snap install marksman"
	@echo "  Or skip it - Markdown files will work without LSP features."
	@echo ""
	@echo "ℹ Optional: Install Ruff for Python LSP support"
	@echo "  Ruff has built-in LSP server support (requires ruff >= 0.3.3)"
	@echo "  To install:"
	@echo "    uv tool install ruff"
	@echo "  Or skip it - Python files will work without LSP features."
	@echo ""
	@echo "Next steps:"
	@echo "  1. Run 'make all' to setup dotfiles"
	@echo "  2. Restart your shell or run 'source ~/.bashrc'"

all:
	@echo "========================================="
	@echo "Setting up dotfiles..."
	@echo "========================================="
	@echo ""
	@echo "Initializing git submodules..."
	@git submodule update --init --recursive
	@echo ""
	@echo "Stowing all packages..."
	@if $(MAKE) stow 2>/dev/null; then \
		echo "✓ All packages stowed successfully!"; \
	else \
		echo ""; \
		echo "⚠ Stow failed! This usually happens when files already exist."; \
		echo "  Run 'make stow-adopt' to merge existing files into the repo."; \
		exit 1; \
	fi
	@echo ""
	@echo "========================================="
	@echo "✓ All dotfiles configured successfully!"
	@echo "========================================="
	@echo ""
	@echo "Optional: Sync VSCode settings (WSL only)"
	@echo "  make vscode-fetch  - Copy VSCode config from Windows to repo"
	@echo "  make vscode-push   - Copy VSCode config from repo to Windows"
	@echo ""
	@echo "Optional: Sync Obsidian vault settings"
	@echo "  make obsidian-fetch - Copy .obsidian settings from vault to repo"
	@echo "  make obsidian-push  - Copy .obsidian settings from repo to vault"

help:
	@echo "Available targets:"
	@echo "  install                   - Install all required dependencies (stow, git, vim, tmux, etc.)"
	@echo "  all                       - Setup dotfiles (stow all packages + install vim plugins)"
	@echo "  stow                      - Stow all packages (bash, git, vim, tmux)"
	@echo "  stow-adopt                - Stow with --adopt (replaces repo files with existing ones)"
	@echo "  unstow                    - Unstow all packages"
	@echo "  stow-bash                 - Stow bash configuration"
	@echo "  stow-git                  - Stow git configuration"
	@echo "  stow-vim                  - Stow vim configuration and auto-install plugins + coc extensions"
	@echo "  stow-tmux                 - Stow tmux configuration"
	@echo "  unstow-bash               - Unstow bash configuration"
	@echo "  unstow-git                - Unstow git configuration"
	@echo "  unstow-vim                - Unstow vim configuration"
	@echo "  unstow-tmux               - Unstow tmux configuration"
	@echo "  vscode-fetch              - Copy VSCode config from Windows to repo (WSL only)"
	@echo "  vscode-push               - Copy VSCode config from repo to Windows (WSL only)"
	@echo "  obsidian-fetch            - Copy .obsidian settings from vault to repo (existing files only)"
	@echo "  obsidian-push             - Copy .obsidian settings from repo to vault"

# Stow targets
stow: stow-bash stow-git stow-vim stow-tmux
	@echo "✓ All packages stowed successfully!"

stow-adopt:
	@echo "Adopting existing files and stowing..."
	@stow -d $(DOTFILES_DIR) -t ~ --adopt bash git vim tmux
	@echo ""
	@echo "✓ All packages stowed with --adopt!"
	@echo ""
	@echo "⚠ Important: Check what changed in the repo:"
	@echo "  git diff"
	@echo ""
	@echo "  To keep repo version: git restore ."
	@echo "  To keep adopted version: git add . && git commit"

unstow: unstow-bash unstow-git unstow-vim unstow-tmux
	@echo "✓ All packages unstowed successfully!"

stow-bash:
	@echo "Stowing bash..."
	@stow -d $(DOTFILES_DIR) -t ~ bash
	@if [ -n "$$BASH_VERSION" ]; then \
		bash -c "source ~/.bashrc" && echo "✓ Bash configuration stowed and reloaded!"; \
	else \
		echo "✓ Bash configuration stowed!"; \
		echo "  Run 'source ~/.bashrc' to reload in current shell."; \
	fi

stow-git:
	@echo "Stowing git..."
	@echo "Generating .gitconfig from template..."
	@sed 's/@GIT_USER_NAME@/$(GIT_USER_NAME)/g; s/@GIT_USER_EMAIL@/$(GIT_USER_EMAIL)/g' \
		$(DOTFILES_DIR)/git/.gitconfig.template > $(DOTFILES_DIR)/git/.gitconfig
	@stow -d $(DOTFILES_DIR) -t ~ git
	@echo "✓ Git configuration stowed!"

stow-vim:
	@echo "Stowing vim..."
	@stow -d $(DOTFILES_DIR) -t ~ vim
	@echo "✓ Vim configuration stowed!"
	@echo "Installing Vim plugins..."
	@vim +PlugInstall +qall 2>/dev/null || echo "  ⚠ Plugin install failed. Run ':PlugInstall' manually in vim."
	@echo "✓ Vim plugins installed!"
	@echo ""
	@echo "ℹ coc.nvim extensions will auto-install when you first open vim"
	@echo "  Extensions: coc-yaml, coc-json"
	@echo "  Language servers: ruff (Python), marksman (Markdown)"
	@echo ""
	@if ! command -v node >/dev/null 2>&1; then \
		echo "  ⚠ Node.js not found! coc.nvim requires Node.js >= 14.14"; \
		echo "  Install via nvm:"; \
		echo "    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"; \
		echo "    source ~/.bashrc"; \
		echo "    nvm install --lts"; \
	fi
	@if ! command -v ruff >/dev/null 2>&1; then \
		echo "  ⚠ Ruff not found! Python LSP requires ruff"; \
		echo "  Install with: uv tool install ruff"; \
	fi

stow-tmux:
	@echo "Stowing tmux..."
	@stow -d $(DOTFILES_DIR) -t ~ tmux
	@echo "Installing TPM plugins..."
	@if [ ! -d ~/.tmux/plugins/tpm ]; then \
		echo "  ⚠ TPM not found. Run 'git submodule update --init --recursive' first."; \
	else \
		~/.tmux/plugins/tpm/bin/install_plugins 2>/dev/null || echo "  ⚠ TPM plugin install failed. Press Prefix + I in tmux to install manually."; \
	fi
	@if [ -n "$$TMUX" ]; then \
		tmux source-file ~/.tmux.conf && echo "✓ Tmux configuration stowed and reloaded!"; \
	else \
		echo "✓ Tmux configuration stowed!"; \
		echo "  Config will load on next tmux session."; \
	fi

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

unstow-tmux:
	@echo "Unstowing tmux..."
	@stow -d $(DOTFILES_DIR) -t ~ -D tmux

# VSCode targets
vscode-fetch:
	@echo "Fetching VSCode configuration from Windows..."
	@mkdir -p $(VSCODE_DIR)
	@if [ -f "$(VSCODE_WIN_USER)/settings.json" ]; then \
		cp "$(VSCODE_WIN_USER)/settings.json" "$(VSCODE_DIR)/settings.json"; \
		echo "  ✓ Copied settings.json"; \
	else \
		echo "  ⚠ settings.json not found at $(VSCODE_WIN_USER)"; \
	fi
	@if [ -f "$(VSCODE_WIN_USER)/keybindings.json" ]; then \
		cp "$(VSCODE_WIN_USER)/keybindings.json" "$(VSCODE_DIR)/keybindings.json"; \
		echo "  ✓ Copied keybindings.json"; \
	else \
		echo "  ⚠ keybindings.json not found"; \
	fi
	@echo "Backing up VSCode extensions list..."
	@cmd.exe /c "code --list-extensions" 2>/dev/null | sed 's/\r$$//' > $(VSCODE_DIR)/extensions.txt
	@echo "  ✓ Saved $(shell wc -l < $(VSCODE_DIR)/extensions.txt 2>/dev/null || echo 0) extensions to extensions.txt"
	@echo "✓ VSCode config and extensions fetched!"

vscode-push:
	@echo "Pushing VSCode configuration to Windows..."
	@if [ -f "$(VSCODE_DIR)/settings.json" ]; then \
		cp "$(VSCODE_DIR)/settings.json" "$(VSCODE_WIN_USER)/settings.json"; \
		echo "  ✓ Copied settings.json to Windows"; \
	else \
		echo "  ⚠ settings.json not found in repo"; \
	fi
	@if [ -f "$(VSCODE_DIR)/keybindings.json" ]; then \
		cp "$(VSCODE_DIR)/keybindings.json" "$(VSCODE_WIN_USER)/keybindings.json"; \
		echo "  ✓ Copied keybindings.json to Windows"; \
	else \
		echo "  ⚠ keybindings.json not found in repo"; \
	fi
	@echo "Installing VSCode extensions..."
	@if [ ! -f "$(VSCODE_DIR)/extensions.txt" ]; then \
		echo "  ⚠ extensions.txt not found! Skipping extension install."; \
	else \
		echo "  Installing $(shell wc -l < $(VSCODE_DIR)/extensions.txt) extensions..."; \
		for ext in $$(cat $(VSCODE_DIR)/extensions.txt); do \
			cmd.exe /c "code --install-extension $$ext" 2>/dev/null | sed 's/\r$$//' || true; \
		done; \
		echo "  ✓ Extensions installation complete!"; \
	fi
	@echo "✓ VSCode config and extensions pushed!"

# Obsidian targets
obsidian-fetch:
	@echo "Fetching Obsidian settings from vault..."
	@if [ ! -d "$(OBSIDIAN_VAULT_PATH)" ]; then \
		echo "  ⚠ Vault not found at $(OBSIDIAN_VAULT_PATH)"; \
		echo "  Set OBSIDIAN_VAULT_PATH in config.mk"; \
		exit 1; \
	fi
	@mkdir -p $(OBSIDIAN_DIR)/.obsidian $(OBSIDIAN_DIR)/templates
	@# Sync .obsidian folder - only copy files that already exist in repo
	@echo "Syncing .obsidian settings..."
	@COPIED=0; \
	for file in $(OBSIDIAN_DIR)/.obsidian/*; do \
		if [ -f "$$file" ]; then \
			filename=$$(basename "$$file"); \
			if [ -f "$(OBSIDIAN_VAULT_PATH)/.obsidian/$$filename" ]; then \
				cp "$(OBSIDIAN_VAULT_PATH)/.obsidian/$$filename" "$(OBSIDIAN_DIR)/.obsidian/$$filename"; \
				echo "  ✓ .obsidian/$$filename"; \
				COPIED=$$((COPIED + 1)); \
			else \
				echo "  ⚠ .obsidian/$$filename not found in vault"; \
			fi; \
		fi; \
	done; \
	if [ $$COPIED -eq 0 ]; then \
		echo "  ⚠ No .obsidian files copied (add files to $(OBSIDIAN_DIR)/.obsidian first)"; \
	fi
	@# Sync templates folder - only copy files that already exist in repo
	@echo "Syncing templates..."
	@COPIED=0; \
	if [ -d "$(OBSIDIAN_VAULT_PATH)/templates" ]; then \
		for file in $(OBSIDIAN_DIR)/templates/*; do \
			if [ -f "$$file" ]; then \
				filename=$$(basename "$$file"); \
				if [ -f "$(OBSIDIAN_VAULT_PATH)/templates/$$filename" ]; then \
					cp "$(OBSIDIAN_VAULT_PATH)/templates/$$filename" "$(OBSIDIAN_DIR)/templates/$$filename"; \
					echo "  ✓ templates/$$filename"; \
					COPIED=$$((COPIED + 1)); \
				else \
					echo "  ⚠ templates/$$filename not found in vault"; \
				fi; \
			fi; \
		done; \
	else \
		echo "  ⚠ templates folder not found in vault"; \
	fi; \
	if [ $$COPIED -eq 0 ]; then \
		echo "  ⚠ No template files copied (add files to $(OBSIDIAN_DIR)/templates first)"; \
	fi
	@echo "✓ Obsidian fetch complete!"

obsidian-push:
	@echo "Pushing Obsidian settings to vault..."
	@if [ ! -d "$(OBSIDIAN_VAULT_PATH)" ]; then \
		echo "  ⚠ Vault not found at $(OBSIDIAN_VAULT_PATH)"; \
		echo "  Set OBSIDIAN_VAULT_PATH in config.mk"; \
		exit 1; \
	fi
	@# Sync .obsidian folder
	@echo "Pushing .obsidian settings..."
	@mkdir -p "$(OBSIDIAN_VAULT_PATH)/.obsidian"
	@COPIED=0; \
	for file in $(OBSIDIAN_DIR)/.obsidian/*; do \
		if [ -f "$$file" ]; then \
			filename=$$(basename "$$file"); \
			cp "$$file" "$(OBSIDIAN_VAULT_PATH)/.obsidian/$$filename"; \
			echo "  ✓ .obsidian/$$filename"; \
			COPIED=$$((COPIED + 1)); \
		fi; \
	done; \
	if [ $$COPIED -eq 0 ]; then \
		echo "  ⚠ No .obsidian files to push"; \
	fi
	@# Sync templates folder
	@echo "Pushing templates..."
	@mkdir -p "$(OBSIDIAN_VAULT_PATH)/templates"
	@COPIED=0; \
	for file in $(OBSIDIAN_DIR)/templates/*; do \
		if [ -f "$$file" ]; then \
			filename=$$(basename "$$file"); \
			cp "$$file" "$(OBSIDIAN_VAULT_PATH)/templates/$$filename"; \
			echo "  ✓ templates/$$filename"; \
			COPIED=$$((COPIED + 1)); \
		fi; \
	done; \
	if [ $$COPIED -eq 0 ]; then \
		echo "  ⚠ No template files to push"; \
	fi
	@echo "✓ Obsidian push complete!"