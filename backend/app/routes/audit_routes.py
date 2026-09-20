from fastapi import APIRouter

from app.controllers.audit_controller import get_all_logs, get_application_logs

router = APIRouter(
    prefix="/audit",
    tags=["Audit"]
)

@router.get("/")
def get_audit_logs():
    """
    Returns all audit logs.
    """
    return get_all_logs()

@router.get("/{application_id}")
def get_audit_logs_for_application(application_id: str):
    """
    Returns all audit logs for a specific application.
    """
    return get_application_logs(application_id)
