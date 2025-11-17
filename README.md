# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/)
and Make.

Works across Windows, WSL, and Linux environments.

## Installation and Setup

Clone this repository with submodules:

```bash
git clone --recursive https://github.com/free41/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Or if you've already cloned it:

```bash
git submodule update --init --recursive
```

Some settings are machine-specific and shouldn't be committed to the repository.
Create a local configuration file:

```bash
cp config.mk.example config.mk
# Edit config.mk with your settings
```

Install dependencies and setup dotfiles in one go:

```bash
make install  # Install all required packages
make all      # Setup dotfiles
```

The `make install` command will install:
- **Core tools**: stow, git, tmux, vim, curl, build-essential
- **Development tools**: universal-ctags, ripgrep, tree, xclip

`make install` will also display instructions for optional dependencies:
- **Node.js** (via nvm) - Required for coc.nvim LSP support
- **code-minimap** (via Rust/cargo) - Optional minimap visualization
- **uv** - Optional Python package and tool manager
- **Marksman** - Optional Markdown language server
- **Ruff** (via uv) - Optional Python language server for linting and formatting

Then `make all` will:
1. Initialize git submodules (including TPM for tmux)
2. Stow all packages
3. Install vim plugins via vim-plug
4. Install tmux plugins via TPM
5. Auto-install coc.nvim extensions (coc-yaml, coc-json) on first vim launch

## VSCode Setup

VSCode settings are synced between WSL and Windows via copy commands (not
stowed). Configure your Windows path in `config.mk`:

```bash
cp config.mk.example config.mk
# Edit VSCODE_WIN_USER to match your Windows VSCode user directory
```

Sync workflow:
- `make vscode-fetch` - Copy settings from Windows to repo (includes extensions
  list)
- `make vscode-push` - Copy settings from repo to Windows and install extensions

Managed files: `settings.json`, `keybindings.json`, `extensions.txt`

## Structure

Each directory represents a package that can be independently installed:

- `bash/` - Bash configuration (.bashrc, .bash_logout)
- `git/` - Git configuration (.gitconfig with privacy settings)
- `vim/` - Vim configuration (.vimrc with nord theme)
- `tmux/` - Tmux configuration (.tmux.conf with nord theme)
- `matplotlib/` - Matplotlib configuration (matplotlibrc with Paul Tol color
  scheme)
- `vscode/` - VSCode configuration (settings.json, extensions.txt)

## Features

### Matplotlib Configuration
- Figure size: 3.3" x 3.0", 300 DPI
- Font size: 9pt
- Inset ticks on all sides
- Paul Tol's vibrant color scheme (colorblind-safe)
- Cycles through both colors and marker symbols
- Default: markers only (no lines)
- Works in virtual environments via `MPLCONFIGDIR`

### Vim Configuration
- **Theme**: Nord
- **Leader key**: Space
- **Plugins**: vim-tmux-navigator, tagbar, NERDTree, minimap.vim, fzf,
  vim-commentary, vim-surround, coc.nvim
- **Features**: Auto-reload files, mouse support in tmux, seamless tmux
  navigation, pipe cursor in insert mode, code minimap, file tree explorer, LSP
  support with Python (coc-ruff), YAML (coc-yaml with Docker Compose schemas),
  JSON (coc-json), and Markdown (Marksman) language servers

### Tmux Configuration
- **Theme**: Nord (via [TPM](https://github.com/tmux-plugins/tpm))
- **Prefix**: Ctrl+a (instead of default Ctrl+b)
- **Features**: Mouse support, 50,000 line scrollback, new windows/panes open in
  current path, automatic window naming based on directory
- **Navigation**: Seamless vim/tmux pane switching with Ctrl+hjkl
- **Plugin Manager**: TPM (Tmux Plugin Manager) is included as a git submodule
  and installed automatically

### VSCode Integration
- Fetch/push settings between Windows and WSL
- Backup and restore extension lists
- See available targets: `make help`

## Available Make Targets

Run `make help` to see all available commands:

- `make install` - Install all required dependencies (stow, git, vim, tmux,
  ctags, ripgrep, code-minimap, etc.)
- `make all` - Setup everything (stow all packages + install vim plugins)
- `make stow` - Stow all packages
- `make unstow` - Remove all symlinks
- `make stow-adopt` - Adopt existing files (useful for initial setup)
- `make stow-vim` - Stow vim configuration and auto-install plugins
- `make vscode-fetch` - Copy VSCode config from Windows to repo (WSL only)
- `make vscode-push` - Copy VSCode config from repo to Windows (WSL only)

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

### Git Aliases

| Alias    | Command                           | Description                                      |
|----------|-----------------------------------|--------------------------------------------------|
| `gs`     | `git status`                      | Show working tree status                         |
| `ga`     | `git add`                         | Add file contents to the index                   |
| `gaa`    | `git add --all`                   | Add all changes to the index                     |
| `gc`     | `git commit`                      | Record changes to the repository                 |
| `gcm`    | `git commit -m`                   | Commit with inline message                       |
| `gacm`   | `git add --all && git commit -m`  | Add all and commit with message                  |
| `gp`     | `git push`                        | Push to remote repository                        |
| `gpl`    | `git pull`                        | Pull from remote repository                      |
| `gf`     | `git fetch`                       | Fetch from remote repository                     |
| `gd`     | `git diff`                        | Show changes between commits, commit and working tree, etc |
| `gdc`    | `git diff --cached`               | Show changes staged for commit                   |
| `gl`     | `git log --oneline --graph --decorate` | Show commit logs in graph format            |
| `gla`    | `git log --oneline --graph --decorate --all` | Show all branches in graph format  |
| `gco`    | `git checkout`                    | Switch branches or restore working tree files    |
| `gsw`    | `git switch`                      | Switch branches (newer alternative to checkout)  |
| `gb`     | `git branch`                      | List, create, or delete branches                 |
| `gba`    | `git branch -a`                   | List all branches (local and remote)             |
| `gdd`    | `gdd [options] [file]`            | Git diff against dev branch (see below)          |

#### gdd - Git Diff Against Dev Branch

Compare your current branch with the dev branch:

```bash
gdd              # Show full diff: current branch vs dev
gdd filename     # Show diff of specific file vs dev
gdd -v           # Open full diff in vim using git difftool
gdd -v filename  # Open specific file diff in vim
```

> **Note**: Custom aliases can be added to `~/.bash_aliases` (git-ignored) and
> will be loaded automatically.

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
| `Ctrl+a [`          | Enter copy mode                                    |
| `Ctrl+a a`          | Enter copy mode (double-tap)                       |
| `v` (in copy mode)  | Begin selection                                    |
| `y` (in copy mode)  | Yank/copy to system clipboard                      |
| `q` (in copy mode)  | Exit copy mode                                     |
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
| `Space g`               | Search with ripgrep (all files)                   | fzf.vim         |
| `Space /`               | Search lines in current buffer                    | fzf.vim         |
| `Space s`               | Search tags (functions, classes, etc.)            | fzf.vim         |
| **Navigation**          |                                                   |                 |
| `Space h`               | Previous buffer                                   | -               |
| `Space l`               | Next buffer                                       | -               |
| `Space j/k`             | Navigate to window down/up (alternative)          | -               |
| `Space n`               | Toggle NERDTree (file explorer)                   | NERDTree        |
| `Space m`               | Toggle minimap (code overview)                    | minimap.vim     |
| `Space t`               | Toggle Tagbar (code structure)                    | tagbar          |
| **Tags**                |                                                   |                 |
| `Space gt`              | Generate/update ctags (respects .gitignore)       | -               |
| `Ctrl+]`                | Jump to tag definition under cursor               | -               |
| `Ctrl+t`                | Jump back from tag                                | -               |
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
| **LSP and Completion**  |                                                   | coc.nvim        |
| `Tab`                   | Navigate to next completion item                  | coc.nvim        |
| `Shift+Tab`             | Navigate to previous completion item              | coc.nvim        |
| `Ctrl+Space`            | Trigger completion manually                       | coc.nvim        |
| `Enter`                 | Accept selected completion                        | coc.nvim        |
| `gd`                    | Go to definition                                  | coc.nvim        |
| `gy`                    | Go to type definition                             | coc.nvim        |
| `gi`                    | Go to implementation                              | coc.nvim        |
| `gr`                    | Go to references                                  | coc.nvim        |
| `K`                     | Show documentation in preview window              | coc.nvim        |
| `[g`                    | Previous diagnostic/error                         | coc.nvim        |
| `]g`                    | Next diagnostic/error                             | coc.nvim        |
| `Space rn`              | Rename symbol                                     | coc.nvim        |
| `Space qf`              | Apply quickfix to current line                    | coc.nvim        |
| `:Format`               | Format current buffer                             | coc.nvim        |
| `:OR`                   | Organize imports                                  | coc.nvim        |
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
## Cross-Platform Notes

### Windows + WSL
- Configure `config.mk` with your Windows VSCode paths
- Use `make vscode-fetch` and `make vscode-push` to sync settings
- Matplotlib config works in both environments via `MPLCONFIGDIR`
- Configure windows terminal to use Nord color scheme

### Environment Variables
The bashrc exports:
- `PATH`: Includes `~/.local/bin`
- `MPLCONFIGDIR`: Points to `~/.config/matplotlib` for matplotlib settings

