from typing import Any, Optional


def find_current_stage(workflow: dict[str, Any]) -> Optional[dict[str, Any]]:
    """
    Returns the current active workflow stage.
    """

    current_stage_name = workflow.get("current_stage")

    for stage in workflow.get("stages", []):
        if stage.get("stage_name") == current_stage_name:
            return stage

    return None


def get_next_stage(workflow: dict[str, Any]) -> Optional[dict[str, Any]]:
    """
    Returns the next workflow stage based on stage order.
    """

    stages = workflow.get("stages", [])

    current_stage = find_current_stage(workflow)

    if not current_stage:
        return None

    current_order = current_stage.get("stage_order")

    for stage in sorted(
        stages,
        key=lambda item: item.get("stage_order", 0)
    ):
        if stage.get("stage_order", 0) > current_order:
            return stage

    return None


def get_completed_stages(
    workflow: dict[str, Any]
) -> list[dict[str, Any]]:
    """
    Returns all completed workflow stages.
    """

    return [
        stage
        for stage in workflow.get("stages", [])
        if stage.get("status") == "Completed"
    ]


def calculate_workflow_progress(
    workflow: dict[str, Any]
) -> float:
    """
    Calculates workflow completion percentage.
    """

    stages = workflow.get("stages", [])

    if not stages:
        return 0.0

    completed_stages = get_completed_stages(workflow)

    progress = (
        len(completed_stages) / len(stages)
    ) * 100

    return round(progress, 2)


def is_workflow_completed(
    workflow: dict[str, Any]
) -> bool:
    """
    Checks whether all workflow stages are completed.
    """

    stages = workflow.get("stages", [])

    if not stages:
        return False

    return all(
        stage.get("status") == "Completed"
        for stage in stages
    )
