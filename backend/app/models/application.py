from typing import Optional, List
from pydantic import BaseModel, Field


class Application(BaseModel):
    application_id: str
    applicant_name: str
    mobile_number: Optional[str] = None

    application_type: str = "Income Certificate"

    status: str
    current_stage: str

    submitted_date: str
    last_updated: str

    assigned_officer_id: Optional[str] = None

    remarks: Optional[str] = None

    required_documents: List[str] = Field(default_factory=list)

    completed_documents: List[str] = Field(default_factory=list)

    estimated_completion_date: Optional[str] = None