# ============================================================================
# BASH CONFIGURATION
# ============================================================================
# ~/.bashrc: executed by bash(1) for non-login shells.

# ----------------------------------------------------------------------------
# Interactive Shell Check
# ----------------------------------------------------------------------------

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ----------------------------------------------------------------------------
# Shell Options
# ----------------------------------------------------------------------------

# Don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it
shopt -s histappend

# History length settings
HISTSIZE=1000
HISTFILESIZE=2000

# Check the window size after each command and update LINES and COLUMNS
shopt -s checkwinsize

# Enable '**' pattern in pathname expansion (match all files and directories)
#shopt -s globstar

# ----------------------------------------------------------------------------
# Less Configuration
# ----------------------------------------------------------------------------

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ----------------------------------------------------------------------------
# Chroot Identification
# ----------------------------------------------------------------------------

# Set variable identifying the chroot you work in (used in the prompt)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# ----------------------------------------------------------------------------
# Prompt Configuration
# ----------------------------------------------------------------------------

# Nerd Font prompt characters
_NRD_L_CAP=$'\ue0b6'   # left rounded opening cap
_NRD_R_CAP=$'\ue0b4'   # right rounded closing cap
_NRD_SEP=$'\ue0b0'     # right chevron — interlocking segment divider
_NRD_BRANCH=$'\ue0a0'  # git branch icon
_E=$'\e'               # ESC — not expanded in double quotes, must use variable

_set_prompt() {
    local last_exit=$?
    local branch short_path="${PWD/#$HOME/~}"
    branch=$(git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')

    local c_host="163;190;140"   # green
    local c_path="129;161;193"   # blue
    local c_branch="235;203;139" # yellow (clean)
    local c_dark="46;52;64"

    if [ -n "$branch" ] && [[ $(git status --porcelain 2>/dev/null) ]]; then
        c_branch="191;97;106"    # red (dirty)
    fi

    # Build PS1 as the full segment bar on one line
    # \001/\002 mark non-printing sequences so bash measures line width correctly
    local o=$'\001' c=$'\002'
    PS1=""
    PS1+="${o}${_E}[38;2;${c_host}m${c}${_NRD_L_CAP}"
    PS1+="${o}${_E}[48;2;${c_host}m${_E}[38;2;${c_dark}m${c} ${HOSTNAME%%.*} "
    PS1+="${o}${_E}[48;2;${c_path}m${_E}[38;2;${c_host}m${c}${_NRD_SEP}"
    PS1+="${o}${_E}[48;2;${c_path}m${_E}[38;2;${c_dark}m${c} ${short_path} "

    if [ -n "$branch" ]; then
        PS1+="${o}${_E}[48;2;${c_branch}m${_E}[38;2;${c_path}m${c}${_NRD_SEP}"
        PS1+="${o}${_E}[48;2;${c_branch}m${_E}[38;2;${c_dark}m${c} ${_NRD_BRANCH} ${branch} "
        PS1+="${o}${_E}[0m${_E}[38;2;${c_branch}m${c}${_NRD_R_CAP}"
    else
        PS1+="${o}${_E}[0m${_E}[38;2;${c_path}m${c}${_NRD_R_CAP}"
    fi

    PS1+="${o}${_E}[0m${c} "

    case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;\u@\h: \w\a\]$PS1"
        ;;
    esac
}

PROMPT_COMMAND=_set_prompt

# Enable color support of ls and add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto -F --group-directories-first'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ----------------------------------------------------------------------------
# Standard Aliases
# ----------------------------------------------------------------------------

# ls aliases
alias l='ls -1 --group-directories-first'         # Vertical list, no hidden files
alias ll='ls -1a --group-directories-first'       # Vertical list with hidden files
alias lll='ls -la --group-directories-first'       # Vertical list with hidden files

# tree alias with common exclusions
alias t='tree -I ".git|__pycache__|*.egg-info|node_modules|.venv|venv|dist|build|*.pyc|.pytest_cache|.mypy_cache|.tox" --gitignore'
alias tt='tree -a -I ".git|__pycache__|*.egg-info|node_modules|.venv|venv|dist|build|*.pyc|.pytest_cache|.mypy_cache|.tox"'

# Git aliases
alias gs='git status'
alias gc='git commit'
alias gcm='git commit -m'
alias gacm='git add --all && git commit -m'
alias gdc='git diff --cached'
alias gdv='git difftool'

# Neovim
alias vim='nvim'

# Ranger - source so cd-on-exit works
alias r='. ranger'

# WSL/Windows integration aliases
alias open='explorer.exe .'
alias e='explorer.exe .'

# Git diff against dev branch
# Usage: gdd [file]           - diff current branch vs dev
# Usage: gdd -v [file]        - open diff in vim
gdd() {
    local use_vim=0
    local file=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--vim)
                use_vim=1
                shift
                ;;
            *)
                file="$1"
                shift
                ;;
        esac
    done

    if [ $use_vim -eq 1 ]; then
        if [ -n "$file" ]; then
            vim -c "DiffviewOpen dev...HEAD -- $file"
        else
            git difftool dev...HEAD
        fi
    else
        if [ -n "$file" ]; then
            git diff dev...HEAD -- "$file"
        else
            git diff dev...HEAD
        fi
    fi
}

# Git worktree add
# Usage: gwa <branch-name>  - add worktree above repo root, tracking remote or creating new branch
gwa() {
    if [ -z "$1" ]; then
        echo "Usage: gwa <branch-name>"
        return 1
    fi

    local branch="$1"
    local git_root
    git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "Error: not in a git repository"
        return 1
    fi

    local parent_dir
    parent_dir=$(dirname "$git_root")
    local worktree_path="$parent_dir/$branch"

    git fetch --all --prune

    if git ls-remote --heads origin "$branch" | grep -q "$branch"; then
        git worktree add "$worktree_path" "$branch"
    else
        git worktree add -b "$branch" "$worktree_path"
    fi

    if [ $? -ne 0 ]; then
        echo "Error: failed to add worktree"
        return 1
    fi

    cd "$worktree_path" || return 1

    if [ -f ".pre-commit-config.yaml" ]; then
        echo "Found .pre-commit-config.yaml, installing pre-commit hooks..."
        uvx pre-commit install
    fi

    echo "Worktree created at $worktree_path"
}

# Fetch and merge branch from remote
# Usage: gfm [branch]  - fetch, pull current branch, and merge branch (defaults to dev) into current branch
gfm() {
    local branch="${1:-dev}"
    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

    if [ $? -ne 0 ]; then
        echo "Error: not in a git repository"
        return 1
    fi

    echo "Fetching from remote..."
    git fetch --all || return 1

    echo "Pulling current branch ($current_branch)..."
    git pull || {
        echo "Warning: could not pull current branch (may not have upstream set)"
    }

    echo "Merging origin/$branch into current branch..."
    git merge "origin/$branch"
}

# Fetch and diff current branch against target branch in vim
# Usage: gfd [branch]  - fetch, pull, and diff current branch vs branch (defaults to dev) in vim
gfd() {
    local target_branch="${1:-dev}"
    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

    if [ $? -ne 0 ]; then
        echo "Error: not in a git repository"
        return 1
    fi

    echo "Fetching from remote..."
    git fetch --all || return 1

    echo "Pulling current branch ($current_branch)..."
    git pull || {
        echo "Warning: could not pull current branch (may not have upstream set)"
    }

    echo "Opening diff: $current_branch vs origin/$target_branch in vim..."
    git difftool "origin/$target_branch...HEAD"
}

# Alert alias for long running commands
# Usage: sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# ----------------------------------------------------------------------------
# Custom Aliases
# ----------------------------------------------------------------------------

# Python project creation
alias py-new='$HOME/dotfiles/python/new-project.sh'

# Load custom aliases from ~/.bash_aliases if it exists
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# ----------------------------------------------------------------------------
# Bash Completion
# ----------------------------------------------------------------------------

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# ----------------------------------------------------------------------------
# Environment Variables
# ----------------------------------------------------------------------------

# Add ~/.local/bin to PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.lmstudio/bin"

# Disable mouse reporting if not in tmux (prevents scroll producing escape codes)
if [ -z "$TMUX" ]; then
    printf '\e[?1000l'
fi

# FZF configuration - use git ls-files in git repos, respecting .gitignore
export FZF_DEFAULT_COMMAND='git ls-files --cached --others --exclude-standard 2>/dev/null || find . -type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# ----------------------------------------------------------------------------
# Node Version Manager (nvm)
# ----------------------------------------------------------------------------

# nvm configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Load nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # Load nvm bash_completion

