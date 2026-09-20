from typing import Optional

from pydantic import BaseModel


class WorkflowStageUpdate(BaseModel):
    application_id: str
    stage_name: str
    status: str
    remarks: Optional[str] = None
    officer_id: Optional[str] = None


class WorkflowStageResponse(BaseModel):
    stage_id: str
    stage_name: str
    stage_order: int
    status: str

    assigned_to: Optional[str] = None
    started_at: Optional[str] = None
    completed_at: Optional[str] = None
    remarks: Optional[str] = None


class WorkflowResponse(BaseModel):
    application_id: str
    current_stage: str
    overall_status: str
    last_updated: str

    stages: list[WorkflowStageResponse]
