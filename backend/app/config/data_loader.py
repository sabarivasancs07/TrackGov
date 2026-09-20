import json
from pathlib import Path
from typing import Any


BASE_DIR = Path(__file__).resolve().parent.parent


def load_json_data(filename: str) -> Any:
    """
    Load JSON data from the app/data directory.
    """

    file_path = BASE_DIR / "data" / filename

    if not file_path.exists():
        raise FileNotFoundError(
            f"Data file not found: {file_path}"
        )

    with open(file_path, "r", encoding="utf-8") as file:
        return json.load(file)


def save_json_data(
    filename: str,
    data: Any
) -> None:
    """
    Save JSON data to the app/data directory.
    """

    file_path = BASE_DIR / "data" / filename

    with open(
        file_path,
        "w",
        encoding="utf-8"
    ) as file:

        json.dump(
            data,
            file,
            indent=4,
            ensure_ascii=False
        )