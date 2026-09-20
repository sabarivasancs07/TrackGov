import uuid
from typing import Any

from app.services.firestore_service import (
    get_collection_documents,
    get_documents_by_field,
    create_document
)
from app.utils.date_utils import get_current_datetime

AUDIT_COLLECTION = "audit_logs"

def get_all_audit_logs() -> list[dict[str, Any]]:
    """
    Returns all audit logs from Firestore.
    """
    return get_collection_documents(AUDIT_COLLECTION)


def get_application_audit_logs(
    application_id: str
) -> list[dict[str, Any]]:
    """
    Returns all audit logs for a specific application.
    """
    return get_documents_by_field(AUDIT_COLLECTION, "application_id", application_id)


def create_audit_log(
    application_id: str,
    action: str,
    performed_by: str,
    performed_by_role: str | None = None,
    description: str | None = None
) -> dict[str, Any]:
    """
    Creates a new audit log object and saves it to Firestore.
    """
    log_id = f"LOG-{uuid.uuid4().hex[:8].upper()}"

    new_log = {
        "log_id": log_id,
        "application_id": application_id,
        "action": action,
        "performed_by": performed_by,
        "performed_by_role": performed_by_role,
        "description": description,
        "timestamp": get_current_datetime()
    }

    create_document(AUDIT_COLLECTION, log_id, new_log)

    return new_log
