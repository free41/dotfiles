#!/usr/bin/env bash
# Claude Code WorktreeCreate hook: make `claude -w <name>` behave like gwa (bash/.bashrc).
# The worktree goes in <repo>/.worktrees/<name> on branch <name> (an existing local or origin
# branch is checked out; otherwise a new branch from the current HEAD), /.worktrees/ is added to
# .git/info/exclude, and the repo's executable .worktree-setup runs there with the main checkout
# as $1. Claude Code reads the last stdout line as the worktree path, so all else goes to stderr.
set -euo pipefail

input=$(cat)
field() { python3 -c 'import json, sys; print(json.loads(sys.argv[1]).get(sys.argv[2], ""))' "$input" "$1"; }
name=$(field name)
cwd=$(field cwd)
[ -n "$name" ] || { echo "worktree-create: no name in hook input" >&2; exit 1; }

# the main checkout, even when launched from inside another worktree
common=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir)
main=$(dirname "$common")
path="$main/.worktrees/$name"

{
    mkdir -p "$common/info"
    grep -qxF '/.worktrees/' "$common/info/exclude" 2>/dev/null || echo '/.worktrees/' >> "$common/info/exclude"

    if [ -d "$path" ]; then
        echo "Reusing worktree $path"
    elif git -C "$main" rev-parse --verify --quiet "refs/heads/$name" >/dev/null ||
         git -C "$main" rev-parse --verify --quiet "refs/remotes/origin/$name" >/dev/null; then
        git -C "$main" worktree add "$path" "$name"
    else
        git -C "$cwd" worktree add -b "$name" "$path" HEAD
    fi

    if [ -x "$path/.worktree-setup" ]; then
        echo "Running .worktree-setup..."
        (cd "$path" && ./.worktree-setup "$main") || echo "Warning: .worktree-setup failed"
    fi
} >&2

echo "$path"
