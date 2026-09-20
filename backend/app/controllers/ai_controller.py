from typing import Any

from google.genai.errors import ServerError

from app.services.firestore_service import get_document_by_id, get_document_by_field
from app.services.ai_service import (
    generate_application_status_explanation,
    generate_delay_explanation,
)
from app.services.delay_service import (
    calculate_application_delay,
)


APPLICATION_COLLECTION = "applications"
WORKFLOW_COLLECTION = "workflow_history"


def get_application_by_id(
    application_id: str
) -> dict[str, Any] | None:
    """
    Finds an application using the application ID.
    """
    return get_document_by_id(APPLICATION_COLLECTION, application_id)


def get_workflow_by_application_id(
    application_id: str
) -> dict[str, Any] | None:
    """
    Finds workflow information using the application ID.
    """
    return get_document_by_field(WORKFLOW_COLLECTION, "application_id", application_id)


def get_ai_status_explanation(
    application_id: str
) -> dict[str, Any] | None:
    """
    Generates an AI explanation for the application's
    current status.
    """

    application = get_application_by_id(
        application_id
    )

    if application is None:
        return None

    workflow = get_workflow_by_application_id(
        application_id
    )

    # Combine application and workflow data
    ai_application_data = {
        **application
    }

    if workflow:

        ai_application_data["current_stage"] = (
            workflow.get("current_stage")
        )

        ai_application_data["overall_status"] = (
            workflow.get("overall_status")
        )

        ai_application_data["workflow_stages"] = (
            workflow.get("stages", [])
        )

    # Generate AI explanation
    try:

        explanation = (
            generate_application_status_explanation(
                ai_application_data
            )
        )

    except ServerError:

        explanation = (
            "The AI explanation service is temporarily "
            "unavailable. Please try again shortly."
        )

    except Exception:

        explanation = (
            "Unable to generate an AI explanation "
            "at the moment."
        )

    return {
        "application_id": application_id,

        "current_stage": ai_application_data.get(
            "current_stage"
        ),

        "overall_status": ai_application_data.get(
            "overall_status"
        ),

        "ai_explanation": explanation
    }


def get_ai_delay_explanation(
    application_id: str
) -> dict[str, Any] | None:
    """
    Generates an AI explanation for a possible
    application delay.
    """

    application = get_application_by_id(
        application_id
    )

    if application is None:
        return None

    workflow = get_workflow_by_application_id(
        application_id
    )

    # Combine application and workflow data
    ai_application_data = {
        **application
    }

    if workflow:

        ai_application_data["current_stage"] = (
            workflow.get("current_stage")
        )

        ai_application_data["overall_status"] = (
            workflow.get("overall_status")
        )

        ai_application_data["workflow_stages"] = (
            workflow.get("stages", [])
        )

    # Calculate delay information
    delay_info = calculate_application_delay(
        ai_application_data
    )

    # Generate AI delay explanation
    try:

        explanation = generate_delay_explanation(
            ai_application_data,
            delay_info
        )

    except ServerError:

        explanation = (
            "The AI delay explanation service is "
            "temporarily unavailable. Please try again shortly."
        )

    except Exception:

        explanation = (
            "Unable to generate an AI delay explanation "
            "at the moment."
        )

    return {
        "application_id": application_id,

        "current_stage": ai_application_data.get(
            "current_stage"
        ),

        "overall_status": ai_application_data.get(
            "overall_status"
        ),

        "delay_info": delay_info,

        "ai_delay_explanation": explanation
    }