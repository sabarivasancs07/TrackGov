from google import genai

from app.config.settings import settings


def get_gemini_client() -> genai.Client:
    """
    Creates and returns the Gemini API client.

    The API key is loaded from the application settings,
    which reads it from the .env file.
    """

    if not settings.GEMINI_API_KEY:
        raise ValueError(
            "GEMINI_API_KEY is not configured. "
            "Please add it to your .env file."
        )

    return genai.Client(
        api_key=settings.GEMINI_API_KEY
    )