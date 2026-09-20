from typing import Any

from google.genai import types
from google.genai.errors import ServerError

from app.config.gemini_config import get_gemini_client
from app.utils.prompt_builder import (
    build_application_status_prompt,
    build_delay_explanation_prompt,
)


MODEL_NAME = "gemini-3.6-flash"


def generate_application_status_explanation(
    application: dict[str, Any]
) -> str:
    """
    Generates a simple, citizen-friendly explanation
    of the application's current status using Gemini AI.
    """

    try:

        client = get_gemini_client()

        prompt = build_application_status_prompt(
            application
        )

        response = client.models.generate_content(
            model=MODEL_NAME,
            contents=prompt,
            config=types.GenerateContentConfig(
                temperature=0.3
            )
        )

        if response.text:
            return response.text

        return (
            "Unable to generate an AI explanation "
            "at the moment."
        )

    except ServerError:

        return (
            "The AI explanation service is temporarily "
            "unavailable. Please try again shortly."
        )

    except Exception:

        return (
            "Unable to generate an AI explanation "
            "at the moment."
        )


def generate_delay_explanation(
    application: dict[str, Any],
    delay_info: dict[str, Any]
) -> str:
    """
    Generates a citizen-friendly explanation
    for an application's possible delay.
    """

    try:

        client = get_gemini_client()

        prompt = build_delay_explanation_prompt(
            application,
            delay_info
        )

        response = client.models.generate_content(
            model=MODEL_NAME,
            contents=prompt,
            config=types.GenerateContentConfig(
                temperature=0.3
            )
        )

        if response.text:
            return response.text

        return (
            "Unable to generate an AI delay explanation "
            "at the moment."
        )

    except ServerError:

        return (
            "The AI delay explanation service is temporarily "
            "unavailable. Please try again shortly."
        )

    except Exception:

        return (
            "Unable to generate an AI delay explanation "
            "at the moment."
        )