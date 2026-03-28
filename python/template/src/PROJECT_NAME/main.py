"""Main module for PROJECT_NAME."""


def hello(name: str = "World") -> str:
    """Return a greeting message.

    Args:
        name: The name to greet. Defaults to "World".

    Returns:
        A greeting message.
    """
    return f"Hello, {name}!"


def main() -> None:
    """Run the main function."""
    print(hello())


if __name__ == "__main__":
    main()


