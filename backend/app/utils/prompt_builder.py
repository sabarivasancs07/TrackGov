from typing import Any
import json


def build_application_status_prompt(
    application: dict[str, Any]
) -> str:
    """
    Builds a prompt for generating a citizen-friendly
    explanation of the application's current status.
    """

    application_data = json.dumps(
        application,
        indent=2,
        default=str
    )

    prompt = f"""
You are an AI assistant for TrackGov AI.

TrackGov AI helps citizens understand the status of their
government Income Certificate applications.

Your task is to explain the application's current status in
simple, clear, citizen-friendly language.

IMPORTANT RULES:

1. Use simple English.
2. Do not use technical terms unless necessary.
3. Do not invent information.
4. Only use the application data provided.
5. Clearly explain the current stage.
6. Explain what has already been completed.
7. Explain what is likely to happen next.
8. Do not promise approval or a specific completion date.
9. Keep the response concise.
10. Be helpful and reassuring.

APPLICATION DATA:

{application_data}

Generate a clear explanation for the citizen.
"""

    return prompt


def build_delay_explanation_prompt(
    application: dict[str, Any],
    delay_info: dict[str, Any]
) -> str:
    """
    Builds a prompt for generating a citizen-friendly
    explanation for a possible application delay.
    """

    application_data = json.dumps(
        application,
        indent=2,
        default=str
    )

    delay_data = json.dumps(
        delay_info,
        indent=2,
        default=str
    )

    prompt = f"""
You are an AI assistant for TrackGov AI.

TrackGov AI helps citizens understand their government
Income Certificate application process.

Your task is to explain a possible delay in simple,
citizen-friendly language.

IMPORTANT RULES:

1. Use simple English.
2. Do not blame any officer or department.
3. Do not invent reasons for the delay.
4. Only use the information provided.
5. Clearly explain whether a delay has been detected.
6. Explain the current application stage.
7. Give a helpful explanation.
8. Do not promise an exact completion date.
9. Keep the response concise and reassuring.

APPLICATION DATA:

{application_data}

DELAY INFORMATION:

{delay_data}

Generate a clear explanation for the citizen.
"""

    return prompt