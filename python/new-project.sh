#!/bin/bash
# Bootstrap a new Python project with uv, ruff, and pre-commit

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <project-name>"
    exit 1
fi

PROJECT_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/template"

echo "Creating new Python project: $PROJECT_NAME"
uv init "$PROJECT_NAME"
cd "$PROJECT_NAME"

echo "Copying template files..."

# Copy template files
cp "$TEMPLATE_DIR/.pre-commit-config.yaml" .
cp "$TEMPLATE_DIR/.gitignore" .
cp "$TEMPLATE_DIR/pyproject.toml" .
cp "$TEMPLATE_DIR/README.md" .

# Create src structure
mkdir -p "src/$PROJECT_NAME"
cp "$TEMPLATE_DIR/src/PROJECT_NAME/__init__.py" "src/$PROJECT_NAME/"

# Copy main.py and base.mplstyle (always include style for potential future use)
cp "$TEMPLATE_DIR/src/PROJECT_NAME/base.mplstyle" "src/$PROJECT_NAME/"
cp "$TEMPLATE_DIR/src/PROJECT_NAME/main.py" "src/$PROJECT_NAME/"

# Create tests structure (empty, user can add tests as needed)
mkdir -p tests
cp "$TEMPLATE_DIR/tests/__init__.py" tests/

# Replace PROJECT_NAME placeholder in all files
find . -type f -not -path "./.git/*" -exec sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" {} +

echo "Syncing dependencies..."
uv sync

echo "Installing pre-commit hooks..."
uv run pre-commit install

echo ""
echo "Done! Project $PROJECT_NAME is ready."
echo ""
echo "Matplotlib style available at: $PROJECT_NAME.base"
echo "  Add matplotlib: uv add matplotlib"
echo "  Use in code: plt.style.use(\"$PROJECT_NAME.base\")"
echo ""
echo "Run 'cd $PROJECT_NAME' to get started."
