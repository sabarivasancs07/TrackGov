from fastapi import APIRouter

from app.controllers.auth_controller import login_officer
from app.schemas.auth_schema import LoginRequest


router = APIRouter(
    prefix="/auth",
    tags=["Authentication"]
)


@router.post("/login")
def login(login_data: LoginRequest):
    """
    Authenticate an officer.
    """

    return login_officer(
        username=login_data.username,
        password=login_data.password
    )
