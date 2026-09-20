from fastapi import APIRouter

from app.controllers.workflow_controller import (
    get_application_workflow,
    get_next_stage,
    update_workflow_stage,
)
from app.schemas.workflow_schema import WorkflowStageUpdate


router = APIRouter(
    prefix="/workflow",
    tags=["Workflow"]
)


@router.get("/{application_id}")
def get_workflow(application_id: str):
    """
    Returns the complete workflow
    for a specific application.
    """

    return get_application_workflow(application_id)


@router.get("/{application_id}/next-stage")
def get_application_next_stage(application_id: str):
    """
    Returns the next workflow stage
    for a specific application.
    """

    return get_next_stage(application_id)


@router.put("/{application_id}/stage")
def update_stage(
    application_id: str,
    update_data: WorkflowStageUpdate
):
    """
    Updates a workflow stage.
    """

    return update_workflow_stage(
        application_id=application_id,
        stage_name=update_data.stage_name,
        status=update_data.status,
        remarks=update_data.remarks,
        officer_id=update_data.officer_id
    ) 
