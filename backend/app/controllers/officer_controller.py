from fastapi import HTTPException


from app.services.auth_service import get_all_officers, get_officer_by_id
from app.services.workflow_service import (
    get_workflow_details,
    prepare_workflow_stage_update,
)


def get_all_officer_details() -> list[dict]:
    """
    Returns all officers without exposing passwords.
    """

    officers = get_all_officers()

    return [
        {
            "officer_id": officer.get("officer_id"),
            "name": officer.get("name"),
            "role": officer.get("role"),
            "department": officer.get("department"),
            "username": officer.get("username"),
            "is_active": officer.get("is_active", True)
        }
        for officer in officers
    ]


def get_officer_details(officer_id: str) -> dict:
    """
    Returns details of a specific officer.
    """

    officer = get_officer_by_id(officer_id)

    if not officer:
        raise HTTPException(
            status_code=404,
            detail="Officer not found"
        )

    return {
        "officer_id": officer.get("officer_id"),
        "name": officer.get("name"),
        "role": officer.get("role"),
        "department": officer.get("department"),
        "email": officer.get("email"),
        "phone_number": officer.get("phone_number"),
        "is_active": officer.get("is_active", True)
    }


def get_officer_assigned_applications(
    officer_id: str
) -> list[dict]:
    """
    Returns all applications assigned to a specific officer.
    """

    officer = get_officer_by_id(officer_id)

    if not officer:
        raise HTTPException(
            status_code=404,
            detail="Officer not found"
        )

    from app.services.firestore_service import get_documents_by_field
    return get_documents_by_field("applications", "assigned_officer_id", officer_id)


def get_officer_application_workflow(
    officer_id: str,
    application_id: str
) -> dict:
    """
    Returns workflow details for an application assigned
    to the specified officer.
    """

    assigned_applications = get_officer_assigned_applications(
        officer_id
    )

    application_exists = any(
        application.get("application_id") == application_id
        for application in assigned_applications
    )

    if not application_exists:
        raise HTTPException(
            status_code=403,
            detail="This application is not assigned to the officer"
        )

    workflow = get_workflow_details(application_id)

    if not workflow:
        raise HTTPException(
            status_code=404,
            detail="Workflow not found"
        )

    return workflow


def update_officer_application_stage(
    officer_id: str,
    application_id: str,
    stage_name: str,
    status: str,
    remarks: str | None = None
) -> dict:
    """
    Prepares a workflow stage update performed by an officer.
    """

    officer = get_officer_by_id(officer_id)

    if not officer:
        raise HTTPException(
            status_code=404,
            detail="Officer not found"
        )

    updated_workflow = prepare_workflow_stage_update(
        application_id=application_id,
        stage_name=stage_name,
        status=status,
        remarks=remarks,
        officer_id=officer_id
    )

    if not updated_workflow:
        raise HTTPException(
            status_code=404,
            detail="Application workflow not found"
        )

    return {
        "success": True,
        "message": "Workflow stage updated successfully",
        "officer_id": officer_id,
        "application_id": application_id,
        "workflow": updated_workflow
    } 
