from copy import deepcopy
from typing import Any

from app.services.firestore_service import (
    get_collection_documents,
    get_document_by_field,
    get_document_id_by_field,
    update_document
)
from app.utils.date_utils import get_current_datetime
from app.utils.workflow_parser import (
    find_current_stage,
    get_next_stage,
    calculate_workflow_progress,
)
from app.services.audit_service import create_audit_log
from app.services.auth_service import get_officer_by_id


WORKFLOW_COLLECTION = "workflow_history"


def get_all_workflows() -> list[dict[str, Any]]:
    """
    Returns all workflow records from Firestore.
    """
    return get_collection_documents(WORKFLOW_COLLECTION)


def get_workflow_by_application_id(
    application_id: str,
) -> dict[str, Any] | None:
    """
    Returns the workflow for a specific application ID from Firestore.
    """
    return get_document_by_field(WORKFLOW_COLLECTION, "application_id", application_id)


def get_workflow_details(
    application_id: str,
) -> dict[str, Any] | None:
    """
    Returns workflow details along with progress information.
    """

    workflow = get_workflow_by_application_id(application_id)

    if workflow is None:
        return None

    current_stage = find_current_stage(workflow)

    return {
        "application_id": workflow.get("application_id"),
        "current_stage": workflow.get("current_stage"),
        "overall_status": workflow.get("overall_status"),
        "last_updated": workflow.get("last_updated"),
        "progress_percentage": calculate_workflow_progress(
            workflow
        ),
        "current_stage_details": current_stage,
        "stages": workflow.get("stages", []),
    }


def get_next_workflow_stage(
    application_id: str,
) -> dict[str, Any] | None:
    """
    Returns the next stage of the application's workflow.
    """

    workflow = get_workflow_by_application_id(application_id)

    if workflow is None:
        return None

    return get_next_stage(workflow)


def prepare_workflow_stage_update(
    application_id: str,
    stage_name: str,
    status: str,
    remarks: str | None = None,
    officer_id: str | None = None,
) -> dict[str, Any] | None:
    """
    Updates a workflow stage, saves the updated workflow
    back to Firestore, synchronizes the application status,
    and creates an audit log entry.

    Workflow progression:

    Pending
        ↓
    In Progress
        ↓
    Completed
        ↓
    Next stage becomes In Progress
    """

    # ---------------------------------------------------------
    # 1. Load workflow
    # ---------------------------------------------------------

    doc_id = get_document_id_by_field(WORKFLOW_COLLECTION, "application_id", application_id)
    if not doc_id:
        return None
    
    workflow = get_workflow_by_application_id(application_id)
    if not workflow:
        return None

    # ---------------------------------------------------------
    # 3. Make a deep copy
    # ---------------------------------------------------------

    updated_workflow = deepcopy(
        workflow
    )

    stages = updated_workflow.get("stages", [])

    if not isinstance(stages, list):
        return None

    # ---------------------------------------------------------
    # 4. Find requested stage
    # ---------------------------------------------------------

    target_stage = None

    for stage in stages:
        if (
            isinstance(stage, dict)
            and stage.get("stage_name") == stage_name
        ):
            target_stage = stage
            break

    if target_stage is None:
        return None

    # ---------------------------------------------------------
    # 5. Update stage status
    # ---------------------------------------------------------

    target_stage["status"] = status

    # ---------------------------------------------------------
    # 6. Update officer
    # ---------------------------------------------------------

    if officer_id is not None:
        target_stage["assigned_to"] = officer_id

    # ---------------------------------------------------------
    # 7. Update remarks
    # ---------------------------------------------------------

    if remarks is not None:
        target_stage["remarks"] = remarks

    # ---------------------------------------------------------
    # 8. If stage starts
    # ---------------------------------------------------------

    if status == "In Progress":

        if not target_stage.get("started_at"):
            target_stage["started_at"] = (
                get_current_datetime()
            )

        target_stage["completed_at"] = None

    # ---------------------------------------------------------
    # 9. If stage is completed
    # ---------------------------------------------------------

    elif status == "Completed":

        if not target_stage.get("started_at"):
            target_stage["started_at"] = (
                get_current_datetime()
            )

        target_stage["completed_at"] = (
            get_current_datetime()
        )

    # ---------------------------------------------------------
    # 10. If stage is pending
    # ---------------------------------------------------------

    elif status == "Pending":

        target_stage["started_at"] = None
        target_stage["completed_at"] = None

    # ---------------------------------------------------------
    # 11. Move to next stage when completed
    # ---------------------------------------------------------

    if status == "Completed":

        next_stage = get_next_stage(
            updated_workflow
        )

        if next_stage is not None:

            next_stage["status"] = "In Progress"

            if not next_stage.get("started_at"):
                next_stage["started_at"] = (
                    get_current_datetime()
                )

            next_stage["completed_at"] = None

            updated_workflow["current_stage"] = (
                next_stage.get("stage_name")
            )

            updated_workflow["overall_status"] = (
                "Under Verification"
            )

        else:
            # No next stage means the entire workflow
            # has been completed.

            updated_workflow["current_stage"] = (
                target_stage.get("stage_name")
            )

            updated_workflow["overall_status"] = (
                "Approved"
            )

    # ---------------------------------------------------------
    # 12. If stage is In Progress
    # ---------------------------------------------------------

    elif status == "In Progress":

        updated_workflow["current_stage"] = (
            target_stage.get("stage_name")
        )

        updated_workflow["overall_status"] = (
            "Under Verification"
        )

    # ---------------------------------------------------------
    # 13. If stage is Pending
    # ---------------------------------------------------------

    elif status == "Pending":

        updated_workflow["current_stage"] = (
            target_stage.get("stage_name")
        )

    elif status == "Rejected":

        target_stage["completed_at"] = (
            get_current_datetime()
        )

        updated_workflow["current_stage"] = (
            target_stage.get("stage_name")
        )

        updated_workflow["overall_status"] = (
            "Rejected"
        )

    # ---------------------------------------------------------
    # 14. Update timestamp
    # ---------------------------------------------------------

    updated_workflow["last_updated"] = (
        get_current_datetime()
    )

    # ---------------------------------------------------------
    # 16. Save updated workflows
    # ---------------------------------------------------------

    update_document(
        WORKFLOW_COLLECTION,
        doc_id,
        updated_workflow
    )

    # ---------------------------------------------------------
    # 16.5 Sync application status and create audit log
    # ---------------------------------------------------------
    app_update = {
        "status": updated_workflow.get("overall_status"),
        "current_stage": updated_workflow.get("current_stage"),
        "last_updated": updated_workflow.get("last_updated")
    }
    # Update the application document in Firestore
    update_document("applications", application_id, app_update)
    
    officer_name = "System"
    officer_role = "Automated"
    if officer_id:
        officer = get_officer_by_id(officer_id)
        if officer:
            officer_name = officer.get("name", officer_id)
            officer_role = officer.get("role", "Officer")
            
    create_audit_log(
        application_id=application_id,
        action=f"Stage '{stage_name}' marked as {status}",
        performed_by=officer_name,
        performed_by_role=officer_role,
        description=remarks
    )

    # ---------------------------------------------------------
    # 17. Return updated workflow
    # ---------------------------------------------------------

    return updated_workflow