from fastapi import HTTPException
from app.services.audit_service import get_all_audit_logs, get_application_audit_logs

def get_all_logs() -> list[dict]:
    """Returns all audit logs."""
    return get_all_audit_logs()

def get_application_logs(application_id: str) -> list[dict]:
    """Returns audit logs for a specific application."""
    logs = get_application_audit_logs(application_id)
    return logs
