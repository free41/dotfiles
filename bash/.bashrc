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

# Set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# Uncomment for a colored prompt, if the terminal has the capability
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48 (ISO/IEC-6429)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# Configure the prompt based on color support
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# ----------------------------------------------------------------------------
# Color Support and Aliases
# ----------------------------------------------------------------------------

# Enable color support of ls and add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ----------------------------------------------------------------------------
# Standard Aliases
# ----------------------------------------------------------------------------

# ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# tree alias with common exclusions
alias t='tree -I ".git|__pycache__|*.egg-info|node_modules|.venv|venv|dist|build|*.pyc|.pytest_cache|.mypy_cache|.tox"'

# Alert alias for long running commands
# Usage: sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# ----------------------------------------------------------------------------
# Custom Aliases
# ----------------------------------------------------------------------------

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

# Matplotlib configuration directory
export MPLCONFIGDIR="$HOME/.config/matplotlib"

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

# ----------------------------------------------------------------------------
# Tmux Auto-start
# ----------------------------------------------------------------------------

# Automatically start tmux if:
# - tmux is installed
# - not already inside a tmux session
# - running in an interactive shell
# - not in VSCode integrated terminal (to avoid conflicts)
if command -v tmux &> /dev/null && [ -z "$TMUX" ] && [ -z "$VSCODE_INJECTION" ]; then
    # If there's no session, create one named "default"
    # Otherwise, attach to the first available session
    if ! tmux has-session 2>/dev/null; then
        exec tmux new-session -s default
    else
        exec tmux attach-session
    fi
fi
