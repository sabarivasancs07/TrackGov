from fastapi import HTTPException
from app.services.firestore_service import get_document_by_id, get_collection_documents
from app.services.workflow_service import get_workflow_details
from app.services.delay_service import calculate_application_delay
from app.utils.validators import validate_application_id

def get_all_applications() -> list[dict]:
    """
    Returns all applications from Firestore.
    """
    return get_collection_documents("applications")


def get_application_detail(application_id: str) -> dict:
    """
    Returns a single application with its workflow and delay information.
    """
    if not validate_application_id(application_id):
        raise HTTPException(
            status_code=400,
            detail="Invalid application ID format"
        )

    application = get_document_by_id("applications", application_id)
    if application is None:
        raise HTTPException(
            status_code=404,
            detail="Application not found"
        )

    workflow = get_workflow_details(application_id)
    delay_info = calculate_application_delay(application)

    return {
        "application": application,
        "workflow": workflow,
        "delay_info": delay_info
    }

def get_application_delay(application_id: str) -> dict:
    """
    Returns delay information for a single application.
    """
    if not validate_application_id(application_id):
        raise HTTPException(
            status_code=400,
            detail="Invalid application ID format"
        )

    application = get_document_by_id("applications", application_id)
    if application is None:
        raise HTTPException(
            status_code=404,
            detail="Application not found"
        )

    return calculate_application_delay(application)
