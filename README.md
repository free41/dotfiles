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
- `python/` - Python project templates and tooling
- `vscode/` - VSCode configuration (settings.json, extensions.txt)

## Features

### Python Project Templates
- **Quick setup**: `py-new project-name` creates a new project with modern Python tooling
- **Pre-configured**: ruff formatting/linting, pre-commit hooks, pytest
- **matplotlib style**: Includes `base.mplstyle` with Paul Tol's colorblind-safe palette
- **Template-based**: Easily customizable templates in `python/template/`
- **Style usage**: `plt.style.use("project_name.base")` - style is distributed with package
- **Managed by uv**: Modern Python package and tool manager

The matplotlib style includes:
- Figure size: 4" x 3.5", 120 DPI (600 DPI for saved figures)
- Font: 9pt Century Gothic
- Inset ticks on all sides
- Paul Tol's vibrant color scheme (colorblind-safe): #EE7733, #0077BB, #33BBEE, #EE3377, #CC3311, #009988, #BBBBBB
- Cycles through both colors and marker symbols (o, s, ^, v, D, p, *)
- Default: markers only (no lines)

### Color Scheme

Nord is used consistently across vim, tmux, and the terminal. The preferred
palette is based on Nord but with colors adjusted for better contrast against
the dark background (`#2E3440`) — matching what Windows Terminal produces with
"Automatically adjust lightness of indistinguishable text" enabled.

| # | Role | Standard Nord | Preferred |
|---|------|--------------|-----------|
| foreground | Normal text | `#D8DEE9` | `#BAC6DD` |
| 8 | Bright black / comments | `#4C566A` | `#626B7A` |
| 2 | Green | `#A3BE8C` | `#B2CD9B` |
| 4 | Blue | `#81A1C1` | `#A8C9EB` |
| 6 | Cyan | `#88C0D0` | `#96CFDF` |
| 14 | Bright cyan | `#8FBCBB` | `#A1CFCE` |
| 1 | Red | `#BF616A` | `#FF9FA7` |

Yellow (`#EBCB8B`), magenta (`#B48EAD`), and white (`#E5E9F0`/`#ECEFF4`) are
unchanged — they already have sufficient contrast on the dark background.

The Cosmic Terminal theme (`cosmic/Nord.ron`) uses the preferred values.

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
| `py-new` | `python/new-project.sh` | Create new Python project with templates      |
| `ls`     | `ls --color=auto`    | Colorized ls output                              |
| `grep`   | `grep --color=auto`  | Colorized grep output                            |
| `fgrep`  | `fgrep --color=auto` | Colorized fgrep output                           |
| `egrep`  | `egrep --color=auto` | Colorized egrep output                           |
| `alert`  | (notification)       | Send notification when long command finishes     |

### Python Project Creation

Create a new Python project with the `py-new` alias:

```bash
py-new my-project
```

This creates a new project with:
- **Modern tooling**: uv for dependency management, ruff for linting/formatting
- **Pre-commit hooks**: Auto-configured with ruff and uv-lock
- **Testing setup**: pytest included as dev dependency
- **matplotlib style**: `base.mplstyle` included in package (Paul Tol colorblind-safe palette)
- **Clean structure**: src layout with tests directory

To use matplotlib in your project:
```bash
cd my-project
uv add matplotlib  # Add matplotlib as dependency
```

Then in your Python code:
```python
import matplotlib.pyplot as plt
plt.style.use("my_project.base")  # Load the custom style
```

The style is distributed as part of your package, so it works anywhere your package is installed!

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
| `gfm`    | `gfm [branch]`                    | Fetch, pull, and merge branch into current (see below) |
| `gfd`    | `gfd [branch]`                    | Fetch, pull, and diff in vim (see below)         |
| `gwa`    | `gwa <branch>`                    | Create git worktree (see below)                  |

#### gdd - Git Diff Against Dev Branch

Compare your current branch with the dev branch:

```bash
gdd              # Show full diff: current branch vs dev
gdd filename     # Show diff of specific file vs dev
gdd -v           # Open full diff in vim using git difftool
gdd -v filename  # Open specific file diff in vim
```

#### gfm - Git Fetch and Merge

Fetch and merge a branch from remote into your current branch:

```bash
gfm              # Fetch all, pull current branch, merge origin/dev
gfm feature-123  # Fetch all, pull current branch, merge origin/feature-123
```

This command:
1. Fetches all branches from remote
2. Pulls the current branch to ensure it's up to date
3. Merges the specified branch (defaults to `dev`) into your current branch

#### gfd - Git Fetch and Diff in Vim

Fetch both branches and open a diff in vim:

```bash
gfd              # Fetch all, pull current branch, diff vs origin/dev in vim
gfd feature-123  # Fetch all, pull current branch, diff vs origin/feature-123 in vim
```

This command:
1. Fetches all branches from remote
2. Pulls the current branch
3. Opens `git difftool` to show the diff between current branch and `origin/<branch>` in vim

#### gwa - Git Worktree Add

Create a new git worktree in a sibling directory:

```bash
gwa feature-123  # Create worktree for feature-123 (tracks remote or creates new branch)
```

This command creates a worktree above the repository root and automatically installs pre-commit hooks if `.pre-commit-config.yaml` is present.

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
make unstow-vim
```
## Cross-Platform Notes

### Windows + WSL
- Configure `config.mk` with your Windows VSCode paths
- Use `make vscode-fetch` and `make vscode-push` to sync settings
- Configure Windows Terminal to use Nord color scheme
- Python projects work seamlessly in both environments

### Environment Variables
The bashrc exports:
- `PATH`: Includes `~/.local/bin`

### Migrating from vim to neovim

 ---
  Do you need to uninstall TPM and coc?

  TPM: The new tmux.conf no longer calls run '~/.tmux/plugins/tpm/tpm' and has no plugins, so TPM is just dead weight.
  The TPM submodule (tmux/.tmux/plugins/tpm) is still in the repo but won't be sourced. You have two options:
  - Leave it (harmless, just takes up space)
  - Remove it properly: git submodule deinit tmux/.tmux/plugins/tpm && git rm tmux/.tmux/plugins/tpm (I'd suggest doing
   this — want me to?)

  The installed nord-tmux plugin at ~/.tmux/plugins/nord-tmux can be deleted: rm -rf ~/.tmux/plugins/

  coc.nvim: You're switching to neovim with native LSP — coc is vim-only and won't be used. The installed coc data
  lives at ~/.config/coc/. You can safely rm -rf ~/.config/coc. The vim plugin itself lives in ~/.vim/plugged/coc.nvim
  and will persist unless you do vim +PlugClean or delete ~/.vim/plugged/.

  ---
  Summary of what was created/changed:

  ┌───────────────────────────┬─────────────────────────────────────────────────────────────────────────────────────┐
  │           File            │                                    What changed                                     │
  ├───────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
  │ nvim/nvim/init.lua        │ New — lazy.nvim bootstrap, loads modules                                            │
  ├───────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
  │ nvim/nvim/lua/options.lua │ New — all vim options + autocommands in Lua                                         │
  ├───────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
  │ nvim/nvim/lua/keymaps.lua │ New — all non-plugin keymaps                                                        │
  ├───────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
  │ nvim/nvim/lua/plugins.lua │ New — all plugins with inline config                                                │
  ├───────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
  │ tmux/.tmux.conf           │ Removed TPM/nord-tmux, inlined Nord colors, fixed true color                        │
  ├───────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
  │ Makefile                  │ Added stow-nvim/unstow-nvim, added neovim to apt install, removed Node/coc          │
  │                           │ references                                                                          │
  └───────────────────────────┴─────────────────────────────────────────────────────────────────────────────────────┘

  Key plugin substitutions with same bindings:

  ┌────────────────┬───────────────────────────────────┬───────────────────────────────────────────────────┐
  │      Old       │                New                │                      Binding                      │
  ├────────────────┼───────────────────────────────────┼───────────────────────────────────────────────────┤
  │ NERDTree       │ neo-tree.nvim                     │ <leader>n                                         │
  ├────────────────┼───────────────────────────────────┼───────────────────────────────────────────────────┤
  │ Tagbar         │ aerial.nvim (LSP, no ctags)       │ <leader>t                                         │
  ├────────────────┼───────────────────────────────────┼───────────────────────────────────────────────────┤
  │ fzf.vim        │ telescope.nvim                    │ <leader>f, <C-p>, <leader>b, <leader>g, <leader>/ │
  ├────────────────┼───────────────────────────────────┼───────────────────────────────────────────────────┤
  │ vim-commentary │ Comment.nvim                      │ gc, <C-_>                                         │
  ├────────────────┼───────────────────────────────────┼───────────────────────────────────────────────────┤
  │ vim-polyglot   │ nvim-treesitter                   │ automatic                                         │
  ├────────────────┼───────────────────────────────────┼───────────────────────────────────────────────────┤
  │ coc.nvim       │ nvim-lspconfig + mason + nvim-cmp │ gd, gr, [g, ]g, <leader>rn, etc.                  │
  ├────────────────┼───────────────────────────────────┼───────────────────────────────────────────────────┤
  │ nord-vim       │ shaunsingh/nord.nvim              │ with color customization hooks                    │
  └────────────────┴───────────────────────────────────┴───────────────────────────────────────────────────┘

  Run make stow-nvim to deploy. On first open, lazy.nvim will auto-install everything, then mason will auto-install
  ruff and basedpyright.

