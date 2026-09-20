from fastapi import HTTPException

from app.services.auth_service import authenticate_officer


def login_officer(
    username: str,
    password: str
) -> dict:
    """
    Authenticates an officer and returns
    the officer's details.
    """

    officer = authenticate_officer(
        username,
        password
    )

    if not officer:
        raise HTTPException(
            status_code=401,
            detail="Invalid username or password"
        )

    return {
        "success": True,
        "message": "Login successful",
        "officer_id": officer.get("officer_id"),
        "name": officer.get("name"),
        "role": officer.get("role"),
        "department": officer.get("department")
    } 
