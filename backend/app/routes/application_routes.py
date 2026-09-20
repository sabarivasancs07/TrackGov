from fastapi import APIRouter
from app.controllers.application_controller import (
    get_all_applications,
    get_application_detail,
    get_application_delay
)

router = APIRouter(
    prefix="/applications",
    tags=["Applications"]
)

@router.get("/")
def get_applications():
    """
    Returns all applications from Firestore.
    """
    return get_all_applications()


@router.get("/{application_id}")
def get_application(application_id: str):
    """
    Returns full details for a single application including workflow and delay info.
    """
    return get_application_detail(application_id)

@router.get("/{application_id}/delay")
def get_application_delay_info(application_id: str):
    """
    Returns delay information for a single application.
    """
    return get_application_delay(application_id)
