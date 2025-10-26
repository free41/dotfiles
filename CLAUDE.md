# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository managed with GNU Stow and Make, designed to work across Windows, WSL, and Linux environments. The repository uses a package-based structure where each directory (`bash/`, `git/`, `vim/`, `tmux/`, `matplotlib/`, `vscode/`) represents an independent configuration package that can be stowed separately.

## Key Architecture Decisions

### Stow-based Symlink Management
- Each package directory mirrors the target filesystem structure
- Most packages stow to `~` (home directory)
- Exception: `matplotlib/` stows to `~/.config/` instead of `~`
- The Makefile wraps stow commands for convenience and consistency

### Cross-Platform Strategy
- **WSL/Windows Integration**: VSCode config is managed via `vscode-fetch` and `vscode-push` targets that copy files between WSL and Windows paths
- **Machine-Specific Config**: `config.mk` (git-ignored) overrides default variables like `VSCODE_WIN_USER` for per-machine customization
- **Matplotlib**: Uses `MPLCONFIGDIR` environment variable (exported in `.bashrc`) to work consistently across all platforms and virtual environments

### Plugin Management
- **Vim**: Uses [vim-plug](https://github.com/junegunn/vim-plug) for plugin management, auto-installed on first run
- **Tmux**: Uses [TPM](https://github.com/tmux-plugins/tpm) (Tmux Plugin Manager) included as a git submodule at `tmux/.tmux/plugins/tpm`
- Both plugin managers are invoked automatically by their respective `stow-*` Makefile targets

### Git Privacy Configuration
- Uses GitHub no-reply email: `free41@users.noreply.github.com`
- Author name: `free41`
- Default branch: `dev` (not `main` or `master`)
- When rewriting commit history, the no-reply email must be preserved

## Common Commands

### Setup and Installation
```bash
make all              # Full setup: init submodules, stow all packages, install plugins
make stow             # Stow all packages (bash, git, vim, tmux, matplotlib)
make stow-adopt       # Stow with --adopt (useful for initial setup, merges existing files)
git submodule update --init --recursive  # Initialize TPM and other submodules
```

### Managing Individual Packages
```bash
make stow-<package>    # Install specific package (bash, git, vim, tmux, matplotlib)
make unstow-<package>  # Remove specific package symlinks
make stow-vim          # Stow vim + auto-install vim-plug plugins
make stow-tmux         # Stow tmux + auto-install TPM plugins
```

### VSCode Sync (WSL/Windows)
```bash
make vscode-fetch               # Copy VSCode settings from Windows to repo
make vscode-push                # Copy VSCode settings from repo to Windows
make vscode-extensions-backup   # Export installed extensions to vscode/extensions.txt
make vscode-extensions-install  # Install extensions from vscode/extensions.txt
```

## Important Configuration Details

### Color Scheme
- **Theme**: Nord color scheme is used consistently across vim, tmux, and Windows Terminal
- **Vim**: Uses `arcticicestudio/nord-vim` plugin
- **Tmux**: Uses `arcticicestudio/nord-tmux` plugin via TPM

### Vim (vim/.vimrc)
- Nord color scheme with true color support
- Leader key: Space
- Plugins: vim-tmux-navigator, tagbar, NERDTree, minimap.vim, fzf, vim-commentary, vim-surround
- Auto-generates ctags on save for common file types

### Tmux (tmux/.tmux.conf)
- Nord color scheme via TPM
- Prefix: Ctrl+a (instead of Ctrl+b)
- Seamless navigation with vim using Ctrl+hjkl
- TPM plugins are installed automatically by `make stow-tmux`
- Manual plugin installation: `Ctrl+a I` (capital i) inside tmux

### Matplotlib (matplotlib/matplotlibrc)
- 3.3" × 3.0" figures at 300 DPI
- Paul Tol's vibrant colorblind-safe palette (#EE7733, #0077BB, #33BBEE, #EE3377, #CC3311, #009988, #BBBBBB)
- Cycles through both colors AND markers (o, s, ^, v, D, p, *)
- Default style: markers only, no lines (`lines.linestyle: None`)
- Requires `MPLCONFIGDIR="$HOME/.config/matplotlib"` in shell environment

### Git Aliases
The `.gitconfig` includes shortcuts:
- `git st` → status
- `git co` → checkout
- `git br` → branch
- `git ci` → commit
- `git lg` → log --oneline --graph --decorate --all

## Adding New Packages

1. Create new directory with filesystem structure (e.g., `tmux/.tmux.conf`)
2. Add `stow-<package>` and `unstow-<package>` targets to Makefile
3. Add package to main `stow` and `unstow` targets
4. Update `.PHONY` declaration and `help` target
5. If the package stows to a non-home location (like matplotlib → `~/.config`), create the target directory first in the stow command

## When Making Changes

- Always update the README.md if adding new packages or significant features
- Color scheme changes should maintain Nord consistency across vim and tmux
- Matplotlib configuration changes should maintain Paul Tol color scheme consistency
- VSCode extensions should be backed up after installing new ones
- Machine-specific paths go in `config.mk`, never commit them to `config.mk.example`
- When adding new tmux plugins, add them to `.tmux.conf` under the `# List of plugins` section
- When adding new vim plugins, add them to `.vimrc` in the `call plug#begin()` section
