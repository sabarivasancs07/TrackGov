from fastapi import APIRouter

from app.controllers.officer_controller import (
    get_all_officer_details,
    get_officer_details,
    get_officer_assigned_applications,
    get_officer_application_workflow,
    update_officer_application_stage,
)
from app.schemas.workflow_schema import WorkflowStageUpdate


router = APIRouter(
    prefix="/officers",
    tags=["Officers"]
)


@router.get("/")
def get_officers():
    """
    Returns all officers.
    """

    return get_all_officer_details()


@router.get("/{officer_id}")
def get_officer(officer_id: str):
    """
    Returns details of a specific officer.
    """

    return get_officer_details(officer_id)


@router.get("/{officer_id}/applications")
def get_assigned_applications(officer_id: str):
    """
    Returns all applications assigned
    to a specific officer.
    """

    return get_officer_assigned_applications(
        officer_id
    )


@router.get(
    "/{officer_id}/applications/{application_id}/workflow"
)
def get_application_workflow(
    officer_id: str,
    application_id: str
):
    """
    Returns workflow details for an application
    assigned to the officer.
    """

    return get_officer_application_workflow(
        officer_id,
        application_id
    )


@router.put(
    "/{officer_id}/applications/{application_id}/workflow"
)
def update_application_workflow(
    officer_id: str,
    application_id: str,
    update_data: WorkflowStageUpdate
):
    """
    Updates the workflow stage of an application.
    """

    return update_officer_application_stage(
        officer_id=officer_id,
        application_id=application_id,
        stage_name=update_data.stage_name,
        status=update_data.status,
        remarks=update_data.remarks
    ) 
