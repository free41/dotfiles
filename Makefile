# Dotfiles Makefile
# Manages symlinks between dotfiles repo and system locations

# Default variables
DOTFILES_DIR := $(shell pwd)
VSCODE_DIR := $(DOTFILES_DIR)/vscode
CODE_BIN := code

# Include machine-specific config if it exists
-include config.mk

.PHONY: all help stow unstow stow-adopt stow-bash stow-git stow-vim unstow-bash unstow-git unstow-vim vscode-fetch vscode-push vscode-extensions-backup vscode-extensions-install

all: stow vscode-fetch vscode-extensions-backup
	@echo "All dotfiles configured!"

help:
	@echo "Available targets:"
	@echo "  all                       - Setup everything (stow + vscode-fetch + extensions backup)"
	@echo "  stow                      - Stow all packages (bash, git, vim)"
	@echo "  stow-adopt                - Stow with --adopt (replaces repo files with existing ones)"
	@echo "  unstow                    - Unstow all packages"
	@echo "  stow-bash                 - Stow bash configuration"
	@echo "  stow-git                  - Stow git configuration"
	@echo "  stow-vim                  - Stow vim configuration"
	@echo "  unstow-bash               - Unstow bash configuration"
	@echo "  unstow-git                - Unstow git configuration"
	@echo "  unstow-vim                - Unstow vim configuration"
	@echo "  vscode-fetch              - Copy VSCode config from Windows to repo"
	@echo "  vscode-push               - Copy VSCode config from repo to Windows"
	@echo "  vscode-extensions-backup  - Export list of installed extensions to vscode/extensions.txt"
	@echo "  vscode-extensions-install - Install extensions from vscode/extensions.txt"

# Stow targets
stow: stow-bash stow-git stow-vim
	@echo "All packages stowed!"

stow-adopt:
	@echo "Adopting existing files and stowing..."
	@stow -d $(DOTFILES_DIR) -t ~ --adopt bash git vim
	@echo "All packages stowed with --adopt! Check git diff to see what changed."

unstow: unstow-bash unstow-git unstow-vim
	@echo "All packages unstowed!"

stow-bash:
	@echo "Stowing bash..."
	@stow -d $(DOTFILES_DIR) -t ~ bash

stow-git:
	@echo "Stowing git..."
	@stow -d $(DOTFILES_DIR) -t ~ git

stow-vim:
	@echo "Stowing vim..."
	@stow -d $(DOTFILES_DIR) -t ~ vim

unstow-bash:
	@echo "Unstowing bash..."
	@stow -d $(DOTFILES_DIR) -t ~ -D bash

unstow-git:
	@echo "Unstowing git..."
	@stow -d $(DOTFILES_DIR) -t ~ -D git

unstow-vim:
	@echo "Unstowing vim..."
	@stow -d $(DOTFILES_DIR) -t ~ -D vim

# VSCode targets
vscode-fetch:
	@echo "Fetching VSCode configuration from Windows..."
	@mkdir -p $(VSCODE_DIR)
	@if [ -f "$(VSCODE_WIN_USER)/settings.json" ]; then \
		cp "$(VSCODE_WIN_USER)/settings.json" "$(VSCODE_DIR)/settings.json"; \
		echo "Copied settings.json to $(VSCODE_DIR)"; \
	fi
	@if [ -f "$(VSCODE_WIN_USER)/keybindings.json" ]; then \
		cp "$(VSCODE_WIN_USER)/keybindings.json" "$(VSCODE_DIR)/keybindings.json"; \
		echo "Copied keybindings.json to $(VSCODE_DIR)"; \
	fi
	@echo "VSCode config fetched!"

vscode-push:
	@echo "Pushing VSCode configuration to Windows..."
	@if [ -f "$(VSCODE_DIR)/settings.json" ]; then \
		cp "$(VSCODE_DIR)/settings.json" "$(VSCODE_WIN_USER)/settings.json"; \
		echo "Copied settings.json to Windows"; \
	fi
	@if [ -f "$(VSCODE_DIR)/keybindings.json" ]; then \
		cp "$(VSCODE_DIR)/keybindings.json" "$(VSCODE_WIN_USER)/keybindings.json"; \
		echo "Copied keybindings.json to Windows"; \
	fi
	@echo "VSCode config pushed!"

vscode-extensions-backup:
	@echo "Backing up VSCode extensions list..."
	@mkdir -p $(VSCODE_DIR)
	@$(CODE_BIN) --list-extensions > $(VSCODE_DIR)/extensions.txt
	@echo "Extensions list saved to $(VSCODE_DIR)/extensions.txt"

vscode-extensions-install:
	@echo "Installing VSCode extensions from $(VSCODE_DIR)/extensions.txt..."
	@if [ ! -f "$(VSCODE_DIR)/extensions.txt" ]; then \
		echo "Error: $(VSCODE_DIR)/extensions.txt not found!"; \
		exit 1; \
	fi
	@cat $(VSCODE_DIR)/extensions.txt | xargs -L 1 $(CODE_BIN) --install-extension
	@echo "Extensions installation complete!"