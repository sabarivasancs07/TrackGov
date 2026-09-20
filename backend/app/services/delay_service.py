from typing import Any

from app.services.firestore_service import get_collection_documents
from app.utils.date_utils import calculate_days_passed


def get_delay_rules() -> list[dict[str, Any]]:
    """
    Returns all delay rules from Firestore.
    """
    return get_collection_documents("delay_rules")


def get_delay_rule_for_stage(
    stage_name: str
) -> dict[str, Any] | None:
    """
    Returns the delay rule for a specific workflow stage.
    """

    delay_rules = get_delay_rules()

    for rule in delay_rules:
        if rule.get("stage_name") == stage_name:
            return rule

    return None


def calculate_application_delay(
    application: dict[str, Any]
) -> dict[str, Any]:
    """
    Calculates whether an application is delayed
    based on its current workflow stage.
    """

    current_stage = application.get("current_stage")
    submitted_date = application.get("submitted_date")

    rule = get_delay_rule_for_stage(current_stage)

    if not rule:
        return {
            "application_id": application.get("application_id"),
            "current_stage": current_stage,
            "days_pending": 0,
            "expected_processing_days": 0,
            "is_delayed": False,
            "reason": "No delay rule configured for this stage."
        }

    days_pending = calculate_days_passed(submitted_date)

    expected_days = rule.get(
        "expected_processing_days",
        0
    )

    is_delayed = days_pending > expected_days

    reason = rule.get(
        "delay_reason",
        "Application is taking longer than expected."
    )

    return {
        "application_id": application.get("application_id"),
        "current_stage": current_stage,
        "days_pending": days_pending,
        "expected_processing_days": expected_days,
        "is_delayed": is_delayed,
        "reason": reason if is_delayed else "Application is within the expected processing time."
    } 
