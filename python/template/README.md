# PROJECT_NAME

Brief description of your project.

## Installation

This project uses [uv](https://docs.astral.sh/uv/) for dependency management.

```bash
# Install dependencies
uv sync

# Install with dev dependencies
uv sync --all-extras
```

## Development

```bash
# Run tests
uv run pytest

# Run tests with coverage
uv run pytest --cov

# Format code
uv run ruff format .

# Lint code
uv run ruff check .

# Fix linting issues
uv run ruff check --fix .
```

## Pre-commit Hooks

This project uses pre-commit hooks to maintain code quality.

```bash
# Install pre-commit hooks
uv run pre-commit install

# Run hooks manually
uv run pre-commit run --all-files
```

## Usage

```python
# Add your usage examples here
```

## License

Add your license information here.
