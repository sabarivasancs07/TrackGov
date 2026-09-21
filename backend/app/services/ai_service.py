from typing import Any
import time

from google.genai import types
from google.genai.errors import ServerError

from app.config.gemini_config import get_gemini_client
from app.utils.prompt_builder import (
    build_application_status_prompt,
    build_delay_explanation_prompt,
)


MODEL_NAME = "gemini-3.7-flash"

MAX_RETRIES = 3
RETRY_DELAYS = [2, 5, 10]


def _generate_content(prompt: str) -> str:
    """
    Generate Gemini content with automatic retry
    for temporary server errors such as HTTP 503.
    """

    client = get_gemini_client()

    for attempt in range(MAX_RETRIES):
        try:
            response = client.models.generate_content(
                model=MODEL_NAME,
                contents=prompt,
                config=types.GenerateContentConfig(
                    temperature=0.3,
                ),
            )

            if response.text:
                return response.text

            print("Gemini returned an empty response.")
            return ""

        except ServerError as e:
            print(
                f"Gemini Server Error "
                f"(attempt {attempt + 1}/{MAX_RETRIES}): "
                f"{type(e).__name__}: {e}"
            )

            if attempt < MAX_RETRIES - 1:
                time.sleep(RETRY_DELAYS[attempt])
            else:
                raise

        except Exception as e:
            print(
                f"Gemini API Error: "
                f"{type(e).__name__}: {e}"
            )
            raise

    return ""


def generate_application_status_explanation(
    application: dict[str, Any],
) -> str:
    """
    Generates a simple, citizen-friendly explanation
    of the application's current status using Gemini AI.
    """

    try:
        prompt = build_application_status_prompt(application)

        result = _generate_content(prompt)

        if result:
            return result

        return (
            "Unable to generate an AI explanation "
            "at the moment."
        )

    except ServerError:
        return (
            "The AI explanation service is temporarily "
            "busy. Please try again shortly."
        )

    except Exception:
        return (
            "Unable to generate an AI explanation "
            "at the moment."
        )


def generate_delay_explanation(
    application: dict[str, Any],
    delay_info: dict[str, Any],
) -> str:
    """
    Generates a citizen-friendly explanation
    for an application's possible delay.
    """

    try:
        prompt = build_delay_explanation_prompt(
            application,
            delay_info,
        )

        result = _generate_content(prompt)

        if result:
            return result

        return (
            "Unable to generate an AI delay explanation "
            "at the moment."
        )

    except ServerError:
        return (
            "The AI delay explanation service is temporarily "
            "busy. Please try again shortly."
        )

    except Exception:
        return (
            "Unable to generate an AI delay explanation "
            "at the moment."
        )