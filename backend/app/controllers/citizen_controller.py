from fastapi import HTTPException

from app.services.delay_service import calculate_application_delay
from app.services.firestore_service import get_document_by_id
from app.services.workflow_service import get_workflow_details
from app.utils.validators import validate_application_id


def get_application_by_id(application_id: str) -> dict:
    """
    Returns an application using its application ID
    from Firestore.
    """

    if not validate_application_id(application_id):
        raise HTTPException(
            status_code=400,
            detail="Invalid application ID format"
        )

    application = get_document_by_id(
        "applications",
        application_id
    )

    if application is None:
        raise HTTPException(
            status_code=404,
            detail="Application not found"
        )

    return application


def track_application(application_id: str, applicant_name: str) -> dict:
    """
    Returns complete tracking information
    for a citizen's application.
    """

    application = get_application_by_id(application_id)

    if application.get("applicant_name", "").lower() != applicant_name.lower():
        raise HTTPException(
            status_code=403,
            detail="Verification failed. Details do not match our records."
        )

    workflow = get_workflow_details(application_id)

    delay_info = calculate_application_delay(application)

    return {
        "application": application,
        "workflow": workflow,
        "delay_info": delay_info
    }


def get_application_status(application_id: str, applicant_name: str) -> dict:
    """
    Returns only the current application status.
    """

    application = get_application_by_id(application_id)

    if application.get("applicant_name", "").lower() != applicant_name.lower():
        raise HTTPException(
            status_code=403,
            detail="Verification failed. Details do not match our records."
        )

    return {
        "application_id": application.get("application_id"),
        "application_type": application.get("application_type"),
        "status": application.get("status"),
        "current_stage": application.get("current_stage"),
        "submitted_date": application.get("submitted_date"),
        "last_updated": application.get("last_updated"),
        "estimated_completion_date": application.get(
            "estimated_completion_date"
        ),
        "remarks": application.get("remarks")
    }