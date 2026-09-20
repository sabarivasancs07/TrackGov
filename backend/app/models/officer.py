from typing import Optional
from pydantic import BaseModel


class Officer(BaseModel):
    officer_id: str

    name: str

    role: str

    department: str = "Revenue Department"

    email: Optional[str] = None

    phone_number: Optional[str] = None

    is_active: bool = True
