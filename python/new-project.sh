#!/bin/bash
# Bootstrap a new Python project with uv, ruff, and pre-commit

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <project-name>"
    exit 1
fi

PROJECT_NAME="$1"

echo "Creating new Python project: $PROJECT_NAME"
uv init "$PROJECT_NAME"
cd "$PROJECT_NAME"

echo "Adding dev dependencies..."
uv add --dev ruff pre-commit pytest

echo "Creating .pre-commit-config.yaml..."
cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/astral-sh/uv-pre-commit
    rev: 0.5.16
    hooks:
      - id: uv-lock

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.8.5
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
EOF

echo "Installing pre-commit hooks..."
uv run pre-commit install

echo "Done! Project $PROJECT_NAME is ready."
echo "Run 'cd $PROJECT_NAME' to get started."
