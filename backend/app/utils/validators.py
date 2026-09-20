import re


APPLICATION_ID_PATTERN = re.compile(
    r"^INC-\d{4}-\d{3,}$",
    re.IGNORECASE
)


MOBILE_NUMBER_PATTERN = re.compile(
    r"^[6-9]\d{9}$"
)


def validate_application_id(application_id: str) -> bool:
    """
    Validates the Income Certificate application ID.

    Example:
    INC-2026-001
    """

    if not application_id:
        return False

    return bool(
        APPLICATION_ID_PATTERN.fullmatch(
            application_id.strip()
        )
    )


def validate_mobile_number(mobile_number: str) -> bool:
    """
    Validates a 10-digit Indian mobile number.
    """

    if not mobile_number:
        return False

    return bool(
        MOBILE_NUMBER_PATTERN.fullmatch(
            mobile_number.strip()
        )
    )


def validate_required_fields(
    data: dict,
    required_fields: list[str]
) -> tuple[bool, list[str]]:
    """
    Checks whether all required fields are present
    and contain a non-empty value.

    Returns:
        (is_valid, missing_fields)
    """

    missing_fields = []

    for field in required_fields:
        value = data.get(field)

        if value is None or (
            isinstance(value, str)
            and not value.strip()
        ):
            missing_fields.append(field)

    return len(missing_fields) == 0, missing_fields
