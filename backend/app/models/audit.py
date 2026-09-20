from typing import Optional
from pydantic import BaseModel


class AuditLog(BaseModel):
    log_id: str

    application_id: str

    action: str

    performed_by: str

    performed_by_role: Optional[str] = None

    description: Optional[str] = None

    timestamp: str 
