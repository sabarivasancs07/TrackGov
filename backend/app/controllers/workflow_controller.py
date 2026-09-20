from fastapi import HTTPException

from app.services.workflow_service import (
    get_workflow_details,
    get_next_workflow_stage,
    prepare_workflow_stage_update,
)


def get_application_workflow(
    application_id: str
) -> dict:
    """
    Returns complete workflow information
    for a specific application.
    """

    workflow = get_workflow_details(application_id)

    if not workflow:
        raise HTTPException(
            status_code=404,
            detail="Workflow not found"
        )

    return workflow


def get_next_stage(
    application_id: str
) -> dict:
    """
    Returns the next workflow stage
    for a specific application.
    """

    next_stage = get_next_workflow_stage(application_id)

    if not next_stage:
        raise HTTPException(
            status_code=404,
            detail="Next workflow stage not found"
        )

    return {
        "application_id": application_id,
        "next_stage": next_stage
    }


def update_workflow_stage(
    application_id: str,
    stage_name: str,
    status: str,
    remarks: str | None = None,
    officer_id: str | None = None
) -> dict:
    """
    Updates a workflow stage.
    """

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
        "message": "Workflow updated successfully",
        "application_id": application_id,
        "workflow": updated_workflow
    }
