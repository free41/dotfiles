# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

Each directory represents a package that can be independently installed:

- `bash/` - Bash configuration (.bashrc, .bash_logout)
- `git/` - Git configuration (.gitconfig)
- `vim/` - Vim configuration (.vimrc, .vim/)
- `vscode/` - VSCode configuration (settings.json, keybindings.json)

## Requirements

Install GNU Stow:

```bash
# Debian/Ubuntu
sudo apt install stow

# macOS
brew install stow

# Arch Linux
sudo pacman -S stow
```

## Installation

Clone this repository to your home directory:

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
```

Install all packages:

```bash
stow */
```

Or install individual packages:

```bash
stow bash
stow vim
stow git
stow vscode
```

## Uninstalling

Remove symlinks for a package:

```bash
cd ~/dotfiles
stow -D bash
```

## Adding New Dotfiles

1. Create a new directory for the package (e.g., `tmux/`)
2. Add your config files with the same structure as they appear in your home directory
3. Run `stow <package-name>` to create symlinks

Example:

```bash
mkdir -p tmux
cp ~/.tmux.conf tmux/.tmux.conf
stow tmux
```
