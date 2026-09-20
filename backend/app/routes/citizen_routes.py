from fastapi import APIRouter

from app.controllers.citizen_controller import (
    get_application_status,
    track_application,
)


router = APIRouter(
    prefix="/citizen",
    tags=["Citizen"]
)


@router.get("/track/{application_id}")
def track_citizen_application(application_id: str, applicant_name: str):
    """
    Returns complete tracking information
    for a citizen's application.
    """

    return track_application(application_id, applicant_name)


@router.get("/status/{application_id}")
def get_citizen_application_status_route(application_id: str, applicant_name: str):
    """
    Returns the current status summary
    of a citizen's application.
    """

    return get_application_status(application_id, applicant_name) 
