from fastapi import APIRouter, HTTPException

from app.controllers.ai_controller import (
    get_ai_status_explanation,
    get_ai_delay_explanation,
)


router = APIRouter(
    prefix="/applications",
    tags=["AI"]
)


@router.get(
    "/{application_id}/ai/status"
)
def get_application_ai_status(
    application_id: str
):
    """
    Returns an AI-generated explanation of the
    application's current status.
    """

    result = get_ai_status_explanation(
        application_id
    )

    if result is None:

        raise HTTPException(
            status_code=404,
            detail="Application not found."
        )

    return {
        "success": True,
        "data": result
    }


@router.get(
    "/{application_id}/ai/delay"
)
def get_application_ai_delay(
    application_id: str
):
    """
    Returns an AI-generated explanation for a
    possible application delay.
    """

    result = get_ai_delay_explanation(
        application_id
    )

    if result is None:

        raise HTTPException(
            status_code=404,
            detail="Application not found."
        )

    return {
        "success": True,
        "data": result
    }