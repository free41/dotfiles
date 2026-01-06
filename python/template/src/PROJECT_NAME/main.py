"""Main module for PROJECT_NAME."""


def hello(name: str = "World") -> str:
    """Return a greeting message.

    Args:
        name: The name to greet. Defaults to "World".

    Returns:
        A greeting message.
    """
    return f"Hello, {name}!"


if __name__ == "__main__":
    print(hello())
