# Dotfiles Makefile
# Manages symlinks between dotfiles repo and system locations

# Default variables
DOTFILES_DIR := $(shell pwd)
VSCODE_DIR := $(DOTFILES_DIR)/vscode
CODE_BIN := code
GIT_USER_NAME := your-git-username
GIT_USER_EMAIL := your-email@example.com

# Include machine-specific config if it exists
-include config.mk

.PHONY: all help install stow unstow stow-adopt stow-bash stow-git stow-vim stow-tmux stow-matplotlib unstow-bash unstow-git unstow-vim unstow-tmux unstow-matplotlib vscode-fetch vscode-push

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
		vim \
		curl \
		build-essential \
		universal-ctags \
		ripgrep \
		tree \
		xclip \
		cargo
	@echo ""
	@echo "Installing code-minimap (required for minimap.vim)..."
	@if command -v code-minimap >/dev/null 2>&1; then \
		echo "  ✓ code-minimap already installed"; \
	else \
		cargo install --locked code-minimap && echo "  ✓ code-minimap installed via cargo"; \
	fi
	@echo ""
	@echo "========================================="
	@echo "✓ All dependencies installed!"
	@echo "========================================="
	@echo ""
	@echo "Next steps:"
	@echo "  1. Run 'make all' to setup dotfiles"
	@echo "  2. Restart your shell or run 'source ~/.bashrc'"

all:
	@echo "========================================="
	@echo "Setting up dotfiles..."
	@echo "========================================="
	@echo ""
	@echo "Step 1: Stowing all packages..."
	@if $(MAKE) stow 2>/dev/null; then \
		echo "✓ All packages stowed successfully!"; \
	else \
		echo ""; \
		echo "⚠ Stow failed! This usually happens when files already exist."; \
		echo "  Run 'make stow-adopt' to merge existing files into the repo."; \
		exit 1; \
	fi
	@echo ""
	@echo "Step 2: Fetching VSCode configuration..."
	@$(MAKE) vscode-fetch
	@if git diff --quiet vscode/ 2>/dev/null; then \
		echo "✓ No VSCode config changes detected."; \
	else \
		echo ""; \
		echo "⚠ VSCode configuration has changed!"; \
		echo "  Review changes with: git diff vscode/"; \
		echo "  To discard changes: git restore vscode/"; \
		echo "  To keep changes: git add vscode/ && git commit"; \
		echo "  To push to Windows: make vscode-push"; \
	fi
	@echo ""
	@echo "========================================="
	@echo "✓ All dotfiles configured successfully!"
	@echo "========================================="

help:
	@echo "Available targets:"
	@echo "  install                   - Install all required dependencies (stow, git, vim, tmux, etc.)"
	@echo "  all                       - Setup everything (stow + vscode-fetch + extensions backup)"
	@echo "  stow                      - Stow all packages (bash, git, vim, tmux, matplotlib)"
	@echo "  stow-adopt                - Stow with --adopt (replaces repo files with existing ones)"
	@echo "  unstow                    - Unstow all packages"
	@echo "  stow-bash                 - Stow bash configuration"
	@echo "  stow-git                  - Stow git configuration"
	@echo "  stow-vim                  - Stow vim configuration"
	@echo "  stow-tmux                 - Stow tmux configuration"
	@echo "  stow-matplotlib           - Stow matplotlib configuration"
	@echo "  unstow-bash               - Unstow bash configuration"
	@echo "  unstow-git                - Unstow git configuration"
	@echo "  unstow-vim                - Unstow vim configuration"
	@echo "  unstow-tmux               - Unstow tmux configuration"
	@echo "  unstow-matplotlib         - Unstow matplotlib configuration"
	@echo "  vscode-fetch              - Copy VSCode config from Windows to repo and backup extensions"
	@echo "  vscode-push               - Copy VSCode config from repo to Windows and install extensions"

# Stow targets
stow: stow-bash stow-git stow-vim stow-tmux stow-matplotlib
	@echo "✓ All packages stowed successfully!"

stow-adopt:
	@echo "Adopting existing files and stowing..."
	@stow -d $(DOTFILES_DIR) -t ~ --adopt bash git vim tmux
	@mkdir -p ~/.config/matplotlib
	@stow -d $(DOTFILES_DIR) -t ~/.config --adopt matplotlib
	@echo ""
	@echo "✓ All packages stowed with --adopt!"
	@echo ""
	@echo "⚠ Important: Check what changed in the repo:"
	@echo "  git diff"
	@echo ""
	@echo "  To keep repo version: git restore ."
	@echo "  To keep adopted version: git add . && git commit"

unstow: unstow-bash unstow-git unstow-vim unstow-tmux unstow-matplotlib
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

stow-tmux:
	@echo "Stowing tmux..."
	@stow -d $(DOTFILES_DIR) -t ~ tmux
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

stow-matplotlib:
	@echo "Stowing matplotlib..."
	@mkdir -p ~/.config/matplotlib
	@stow -d $(DOTFILES_DIR) -t ~/.config matplotlib
	@echo "✓ Matplotlib configuration stowed!"

unstow-matplotlib:
	@echo "Unstowing matplotlib..."
	@stow -d $(DOTFILES_DIR) -t ~/.config -D matplotlib

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