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

.PHONY: all help stow unstow stow-adopt stow-bash stow-git stow-vim stow-matplotlib unstow-bash unstow-git unstow-vim unstow-matplotlib vscode-fetch vscode-push vscode-extensions-backup vscode-extensions-install

all: stow vscode-fetch vscode-extensions-backup
	@echo "All dotfiles configured!"

help:
	@echo "Available targets:"
	@echo "  all                       - Setup everything (stow + vscode-fetch + extensions backup)"
	@echo "  stow                      - Stow all packages (bash, git, vim, matplotlib)"
	@echo "  stow-adopt                - Stow with --adopt (replaces repo files with existing ones)"
	@echo "  unstow                    - Unstow all packages"
	@echo "  stow-bash                 - Stow bash configuration"
	@echo "  stow-git                  - Stow git configuration"
	@echo "  stow-vim                  - Stow vim configuration"
	@echo "  stow-matplotlib           - Stow matplotlib configuration"
	@echo "  unstow-bash               - Unstow bash configuration"
	@echo "  unstow-git                - Unstow git configuration"
	@echo "  unstow-vim                - Unstow vim configuration"
	@echo "  unstow-matplotlib         - Unstow matplotlib configuration"
	@echo "  vscode-fetch              - Copy VSCode config from Windows to repo"
	@echo "  vscode-push               - Copy VSCode config from repo to Windows"
	@echo "  vscode-extensions-backup  - Export list of installed extensions to vscode/extensions.txt"
	@echo "  vscode-extensions-install - Install extensions from vscode/extensions.txt"

# Stow targets
stow: stow-bash stow-git stow-vim stow-matplotlib
	@echo "All packages stowed!"

stow-adopt:
	@echo "Adopting existing files and stowing..."
	@stow -d $(DOTFILES_DIR) -t ~ --adopt bash git vim matplotlib
	@echo "All packages stowed with --adopt! Check git diff to see what changed."

unstow: unstow-bash unstow-git unstow-vim unstow-matplotlib
	@echo "All packages unstowed!"

stow-bash:
	@echo "Stowing bash..."
	@stow -d $(DOTFILES_DIR) -t ~ bash

stow-git:
	@echo "Stowing git..."
	@echo "Generating .gitconfig from template..."
	@sed 's/@GIT_USER_NAME@/$(GIT_USER_NAME)/g; s/@GIT_USER_EMAIL@/$(GIT_USER_EMAIL)/g' \
		$(DOTFILES_DIR)/git/.gitconfig.template > $(DOTFILES_DIR)/git/.gitconfig
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
	@rm -f $(DOTFILES_DIR)/git/.gitconfig
	@echo "Removed generated .gitconfig"

unstow-vim:
	@echo "Unstowing vim..."
	@stow -d $(DOTFILES_DIR) -t ~ -D vim

stow-matplotlib:
	@echo "Stowing matplotlib..."
	@mkdir -p ~/.config/matplotlib
	@stow -d $(DOTFILES_DIR) -t ~/.config matplotlib

unstow-matplotlib:
	@echo "Unstowing matplotlib..."
	@stow -d $(DOTFILES_DIR) -t ~/.config -D matplotlib

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
	@cmd.exe /c "code --list-extensions" 2>/dev/null | sed 's/\r$$//' > $(VSCODE_DIR)/extensions.txt
	@echo "Extensions list saved to $(VSCODE_DIR)/extensions.txt"

vscode-extensions-install:
	@echo "Installing VSCode extensions from $(VSCODE_DIR)/extensions.txt..."
	@if [ ! -f "$(VSCODE_DIR)/extensions.txt" ]; then \
		echo "Error: $(VSCODE_DIR)/extensions.txt not found!"; \
		exit 1; \
	fi
	@for ext in $$(cat $(VSCODE_DIR)/extensions.txt); do \
		cmd.exe /c "code --install-extension $$ext" 2>/dev/null | sed 's/\r$$//' || true; \
	done
	@echo "Extensions installation complete!"