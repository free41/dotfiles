# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/) and Make.

Works across Windows, WSL, and Linux environments.

## Structure

Each directory represents a package that can be independently installed:

- `bash/` - Bash configuration (.bashrc, .bash_logout)
- `git/` - Git configuration (.gitconfig with privacy settings)
- `vim/` - Vim configuration (.vimrc)
- `matplotlib/` - Matplotlib configuration (matplotlibrc with Paul Tol color scheme)
- `vscode/` - VSCode configuration (settings.json, extensions.txt)

## Requirements

Install GNU Stow:

```bash
# Debian/Ubuntu/WSL
sudo apt install stow

# macOS
brew install stow

# Arch Linux
sudo pacman -S stow
```

## Installation

Clone this repository:

```bash
git clone https://github.com/free41/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### Quick Setup

Use the Makefile for automated setup:

```bash
make all
```

This will stow all packages, fetch VSCode config (if on Windows/WSL), and backup extensions.

### Manual Installation

Install all packages:

```bash
make stow
```

Or install individual packages:

```bash
make stow-bash
make stow-git
make stow-vim
make stow-matplotlib
```

### Machine-Specific Configuration

Copy the example config and customize for your machine:

```bash
cp config.mk.example config.mk
# Edit config.mk with your Windows paths (if using WSL)
```

## Features

### Git Configuration
- Uses GitHub no-reply email for privacy
- Configured with sensible defaults and useful aliases
- Author: free41 <free41@users.noreply.github.com>

### Matplotlib Configuration
- Figure size: 3.3" x 3.0", 300 DPI
- Font size: 9pt
- Inset ticks on all sides
- Paul Tol's vibrant color scheme (colorblind-safe)
- Cycles through both colors and marker symbols
- Default: markers only (no lines)
- Works in virtual environments via `MPLCONFIGDIR`

### VSCode Integration
- Fetch/push settings between Windows and WSL
- Backup and restore extension lists
- See available targets: `make help`

## Available Make Targets

Run `make help` to see all available commands:

- `make all` - Setup everything
- `make stow` - Stow all packages
- `make unstow` - Remove all symlinks
- `make stow-adopt` - Adopt existing files (useful for initial setup)
- `make vscode-fetch` - Copy VSCode config from Windows to repo
- `make vscode-push` - Copy VSCode config from repo to Windows
- `make vscode-extensions-backup` - Export installed extensions
- `make vscode-extensions-install` - Install extensions from list

## Uninstalling

Remove symlinks for all packages:

```bash
make unstow
```

Or remove individual packages:

```bash
make unstow-bash
make unstow-matplotlib
```

## Adding New Dotfiles

1. Create a new directory for the package
2. Add your config files with the same structure as they appear in your home directory
3. Add stow targets to the Makefile
4. Run `make stow-<package-name>`

## Cross-Platform Notes

### Windows + WSL
- Configure `config.mk` with your Windows VSCode paths
- Use `make vscode-fetch` and `make vscode-push` to sync settings
- Matplotlib config works in both environments via `MPLCONFIGDIR`

### Environment Variables
The bashrc exports:
- `PATH`: Includes `~/.local/bin`
- `MPLCONFIGDIR`: Points to `~/.config/matplotlib` for matplotlib settings
