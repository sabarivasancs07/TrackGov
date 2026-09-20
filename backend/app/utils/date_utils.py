from datetime import datetime, date


def get_current_datetime() -> str:
    """
    Returns the current date and time
    in ISO format.
    """
    return datetime.now().isoformat()


def get_current_date() -> str:
    """
    Returns the current date in YYYY-MM-DD format.
    """
    return date.today().isoformat()


def parse_date(date_string: str) -> datetime:
    """
    Converts a YYYY-MM-DD string into
    a datetime object.
    """
    return datetime.strptime(date_string, "%Y-%m-%d")


def calculate_days_passed(start_date: str) -> int:
    """
    Calculates how many days have passed
    since the given date.
    """
    start = parse_date(start_date).date()
    today = date.today()

    return (today - start).days


def calculate_days_between(
    start_date: str,
    end_date: str
) -> int:
    """
    Calculates the number of days between
    two dates.
    """
    start = parse_date(start_date).date()
    end = parse_date(end_date).date()

    return (end - start).days 
