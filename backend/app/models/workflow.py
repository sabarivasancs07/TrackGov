from typing import Optional
from pydantic import BaseModel


class WorkflowStage(BaseModel):
    stage_id: str
    stage_name: str
    stage_order: int

    status: str = "Pending"

    assigned_to: Optional[str] = None

    started_at: Optional[str] = None
    completed_at: Optional[str] = None

    remarks: Optional[str] = None


class WorkflowHistory(BaseModel):
    application_id: str

    stages: list[WorkflowStage]

    current_stage: str

    overall_status: str

    last_updated: str 
