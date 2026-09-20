from typing import Any

from app.services.firestore_service import get_collection_documents


def get_all_officers() -> list[dict[str, Any]]:
    """
    Returns all officers from Firestore.
    """
    return get_collection_documents("officers")


def authenticate_officer(
    username: str,
    password: str
) -> dict[str, Any] | None:
    """
    Authenticates an officer using username and password.

    This is a demo/hackathon authentication system.
    """

    officers = get_all_officers()

    for officer in officers:
        if (
            (officer.get("username") == username or officer.get("officer_id") == username)
            and officer.get("password") == password
        ):
            return {
                "officer_id": officer.get("officer_id"),
                "name": officer.get("name"),
                "role": officer.get("role"),
                "department": officer.get("department")
            }

    return None


def get_officer_by_id(
    officer_id: str
) -> dict[str, Any] | None:
    """
    Returns an officer using their officer ID.
    """

    officers = get_all_officers()

    for officer in officers:
        if officer.get("officer_id") == officer_id:
            return officer

    return None 
