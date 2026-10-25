#!/usr/bin/env bash
# Claude Code WorktreeRemove hook, paired with worktree-create.sh. Claude Code runs it only after
# its own exit checks (no changes, or you chose "remove"), so the worktree is removed with
# --force. Its branch is deleted with `git branch -d`, which keeps any branch that isn't merged
# yet, and only when the worktree sits at .worktrees/<branch> as worktree-create.sh made it.
set -euo pipefail

input=$(cat)
path=$(python3 -c 'import json, sys; print(json.loads(sys.argv[1]).get("worktree_path", ""))' "$input")
[ -n "$path" ] && [ -d "$path" ] || exit 0

branch=$(git -C "$path" symbolic-ref --quiet --short HEAD || true)
common=$(git -C "$path" rev-parse --path-format=absolute --git-common-dir)
main=$(dirname "$common")

git -C "$main" worktree remove --force "$path" >&2
if [ -n "$branch" ] && [ "$path" = "$main/.worktrees/$branch" ]; then
    git -C "$main" branch -d "$branch" >&2 || echo "Kept branch $branch (not fully merged)" >&2
fi
