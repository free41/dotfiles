# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/) and Make.

Works across Windows, WSL, and Linux environments.

## Structure

Each directory represents a package that can be independently installed:

- `bash/` - Bash configuration (.bashrc, .bash_logout)
- `git/` - Git configuration (.gitconfig with privacy settings)
- `vim/` - Vim configuration (.vimrc with Everforest theme)
- `tmux/` - Tmux configuration (.tmux.conf with Everforest theme)
- `matplotlib/` - Matplotlib configuration (matplotlibrc with Paul Tol color scheme)
- `vscode/` - VSCode configuration (settings.json, extensions.txt)

## Requirements

Install required packages (Ubuntu/Debian/WSL):

```bash
sudo apt install stow tmux universal-ctags ripgrep tree
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
make stow-tmux
make stow-matplotlib
```

### Machine-Specific Configuration

Some settings are machine-specific and shouldn't be committed to the repository. Create a local configuration file:

```bash
cp config.mk.example config.mk
# Edit config.mk with your settings
```

The `config.mk` file (git-ignored) allows you to customize:

| Variable            | Purpose                                        | Example                                                   |
|---------------------|------------------------------------------------|-----------------------------------------------------------|
| `VSCODE_WIN_USER`   | VSCode User directory path for WSL/Windows     | `/mnt/c/Users/yourusername/AppData/Roaming/Code/User`    |
| `GIT_USER_NAME`     | Git author name for commit signing             | `yourusername`                                            |
| `GIT_USER_EMAIL`    | Git author email for commit signing            | `youremail@example.com`                                   |

These variables override the defaults in the Makefile and are used when stowing git configuration or syncing VSCode settings.

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

### Vim Configuration
- **Theme**: Everforest dark medium
- **Leader key**: Space
- **Plugins**: vim-tmux-navigator, tagbar, fzf, vim-commentary, vim-surround
- **Features**: Auto-reload files, mouse support in tmux, seamless tmux navigation

### Tmux Configuration
- **Theme**: Everforest dark medium
- **Prefix**: Ctrl+a (instead of default Ctrl+b)
- **Features**: Mouse support, 50,000 line scrollback, new windows/panes open in current path
- **Navigation**: Seamless vim/tmux pane switching with Ctrl+hjkl

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

## Bash Aliases

Standard aliases included in the dotfiles:

| Alias    | Command              | Description                                      |
|----------|----------------------|--------------------------------------------------|
| `ll`     | `ls -alF`            | Long listing with all files and indicators       |
| `la`     | `ls -A`              | List all files except . and ..                   |
| `l`      | `ls -CF`             | List in columns with indicators                  |
| `t`      | `tree -I "..."`      | Tree view excluding `.git`, `__pycache__`, `node_modules`, etc. |
| `ls`     | `ls --color=auto`    | Colorized ls output                              |
| `grep`   | `grep --color=auto`  | Colorized grep output                            |
| `fgrep`  | `fgrep --color=auto` | Colorized fgrep output                           |
| `egrep`  | `egrep --color=auto` | Colorized egrep output                           |
| `alert`  | (notification)       | Send notification when long command finishes     |

> **Note**: Custom aliases can be added to `~/.bash_aliases` (git-ignored) and will be loaded automatically.

## Custom Keybindings

### Window Management (Parallel Bindings)

These commands work similarly in both vim and tmux for consistent muscle memory:

| Action                    | Vim          | Tmux         |
|---------------------------|--------------|--------------|
| **Horizontal split**      | `Ctrl+w s`   | `Ctrl+a s`   |
| **Vertical split**        | `Ctrl+w v`   | `Ctrl+a v`   |
| **Close window/pane**     | `Ctrl+w q`   | `Ctrl+a q`   |
| **Go to first window/tab**| `Ctrl+w 0`   | `Ctrl+a 0`   |
| **Equalize sizes**        | `Ctrl+w =`   | `Ctrl+a =`   |
| **Maximize/zoom**         | `Ctrl+w _`   | `Ctrl+a _`   |
| **Navigate left**         | `Ctrl+h`     | `Ctrl+h`     |
| **Navigate down**         | `Ctrl+j`     | `Ctrl+j`     |
| **Navigate up**           | `Ctrl+k`     | `Ctrl+k`     |
| **Navigate right**        | `Ctrl+l`     | `Ctrl+l`     |

> **Note**: Navigation with `Ctrl+hjkl` works seamlessly across vim splits and tmux panes!

### Tmux Keybindings

**Prefix Key**: `Ctrl+a` (replaces default `Ctrl+b`)

| Keybinding          | Action                                             |
|---------------------|----------------------------------------------------|
| `Ctrl+a c`          | Create new window (in current path)                |
| `Ctrl+a ,`          | Rename current window                              |
| `Ctrl+a d`          | Detach from session                                |
| `Ctrl+a r`          | Reload tmux configuration                          |
| `Ctrl+a Ctrl+l`     | Clear screen (since Ctrl+l is used for navigation) |
| **Copy Mode**       |                                                    |
| `Escape`            | Enter copy mode                                    |
| `Ctrl+a a`          | Enter copy mode (double-tap)                       |
| `v` (in copy mode)  | Begin selection                                    |
| `y` (in copy mode)  | Yank/copy to system clipboard                      |
| `Ctrl+a p`          | Paste                                              |
| **Mouse Support**   |                                                    |
| Scroll              | Navigate history                                   |
| Click               | Select panes                                       |
| Drag border         | Resize panes                                       |
| Click window name   | Switch windows                                     |

### Vim Keybindings

**Leader Key**: `Space`

| Keybinding              | Action                                            | Plugin          |
|-------------------------|---------------------------------------------------|-----------------|
| **Fuzzy Finding (FZF)** |                                                   |                 |
| `Space f` or `Ctrl+p`   | Find files                                        | fzf.vim         |
| `Space b`               | Switch buffers                                    | fzf.vim         |
| `Space g`               | Search with ripgrep                               | fzf.vim         |
| `Space s`               | Search tags (functions, classes, etc.)            | fzf.vim         |
| **Navigation**          |                                                   |                 |
| `Space h/j/k/l`         | Navigate to window (alternative)                  | -               |
| `Space t`               | Toggle Tagbar (code structure)                    | tagbar          |
| **Tags**                |                                                   |                 |
| `Space gt`              | Generate/update ctags (respects .gitignore)       | -               |
| Auto-generates on save  | For `.c`, `.cpp`, `.h`, `.py`, `.js`, `.ts`, `.go`, `.rs` files | -               |
| **Editing**             |                                                   |                 |
| `Ctrl+/`                | Toggle comment line/selection                     | vim-commentary  |
| `gc{motion}`            | Comment using motion (e.g., `gcap` for paragraph) | vim-commentary  |
| `gcc`                   | Comment current line                              | vim-commentary  |
| `cs"'`                  | Change surrounding " to '                         | vim-surround    |
| `ds"`                   | Delete surrounding "                              | vim-surround    |
| `ysiw]`                 | Surround word with []                             | vim-surround    |
| `S{char}` (visual)      | Surround selection with character                 | vim-surround    |
| **Spell Check**         |                                                   |                 |
| `Space sp`              | Toggle spell check on/off                         | -               |
| `Space sn`              | Jump to next spelling error                       | -               |
| `Space sb`              | Jump to previous spelling error                   | -               |
| `Space sa`              | Add word to dictionary                            | -               |
| `Space s?`              | Show spelling suggestions                         | -               |
| **Other**               |                                                   |                 |
| `Space w`               | Quick save                                        | -               |
| `Esc`                   | Clear search highlighting                         | -               |
| Mouse                   | Full mouse support (scroll, click, select)        | -               |

## Uninstalling

Remove symlinks for all packages:

```bash
make unstow
```

Or remove individual packages:

```bash
make unstow-bash
make unstow-tmux
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
