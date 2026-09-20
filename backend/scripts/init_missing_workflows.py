"""
One-time initialization script for missing workflow_history records in TrackGov AI.

Features:
- Reads applications from Firestore.
- Checks whether each application already has a workflow_history document.
- Does NOTHING to applications that already have a workflow (preserves INC-2026-001).
- Creates workflow_history only for missing applications (INC-2026-002, INC-2026-003, INC-2026-004).
- Uses the existing workflow stages, field names, and structures expected by TrackGov AI.
- Initializes workflow consistently with each application's:
    * application_id
    * current_stage
    * status
    * assigned_officer_id
- Default mode is DRY-RUN (shows exact records without modifying Firestore).
- Run with --apply to execute the creation in Firestore.
"""

import sys
import json
import argparse
from pathlib import Path
from typing import Any

# Ensure backend root is on sys.path
BASE_DIR = Path(__file__).resolve().parents[1]
if str(BASE_DIR) not in sys.path:
    sys.path.insert(0, str(BASE_DIR))

from app.services.firestore_service import db, get_collection_documents

APPLICATION_COLLECTION = "applications"
WORKFLOW_COLLECTION = "workflow_history"

# Standard workflow stage definitions expected across TrackGov AI
CANONICAL_STAGES = [
    {
        "stage_id": "STAGE-001",
        "stage_name": "Application Submitted",
        "stage_order": 1,
    },
    {
        "stage_id": "STAGE-002",
        "stage_name": "Document Verification",
        "stage_order": 2,
    },
    {
        "stage_id": "STAGE-003",
        "stage_name": "Officer Verification",
        "stage_order": 3,
    },
    {
        "stage_id": "STAGE-004",
        "stage_name": "Field Verification",
        "stage_order": 4,
    },
    {
        "stage_id": "STAGE-005",
        "stage_name": "Final Approval",
        "stage_order": 5,
    },
]

STAGE_ORDER_MAP = {s["stage_name"]: s["stage_order"] for s in CANONICAL_STAGES}


def format_iso_timestamp(date_str: str | None, default_time: str = "09:00:00") -> str | None:
    """Helper to convert YYYY-MM-DD or existing datetime into ISO timestamp."""
    if not date_str:
        return None
    if "T" in date_str:
        return date_str
    return f"{date_str}T{default_time}"


def build_workflow_record(app: dict[str, Any]) -> dict[str, Any]:
    """
    Constructs the workflow_history record consistently with the application's
    current_stage, status, assigned_officer_id, submitted_date, and remarks.
    """
    app_id = app.get("application_id")
    current_stage_name = app.get("current_stage")
    overall_status = app.get("status")
    assigned_officer_id = app.get("assigned_officer_id")
    submitted_date = app.get("submitted_date")
    last_updated_date = app.get("last_updated") or submitted_date
    remarks = app.get("remarks")

    submitted_iso = format_iso_timestamp(submitted_date, "09:00:00")
    last_updated_iso = format_iso_timestamp(last_updated_date, "12:00:00")

    current_stage_order = STAGE_ORDER_MAP.get(current_stage_name, 1)

    stages: list[dict[str, Any]] = []

    for stage_def in CANONICAL_STAGES:
        s_id = stage_def["stage_id"]
        s_name = stage_def["stage_name"]
        s_order = stage_def["stage_order"]

        if overall_status == "Approved":
            # All stages completed
            if s_order == 1:
                stage_status = "Completed"
                stage_assigned = None
                started_at = submitted_iso
                completed_at = submitted_iso
                stage_remarks = "Application submitted successfully."
            elif s_order == current_stage_order:
                stage_status = "Completed"
                stage_assigned = assigned_officer_id
                started_at = format_iso_timestamp(last_updated_date, "10:00:00")
                completed_at = last_updated_iso
                stage_remarks = remarks or "Stage completed successfully."
            else:
                stage_status = "Completed"
                if s_order == 2:
                    stage_assigned = "OFF-001"
                elif s_order in (3, 4):
                    stage_assigned = "OFF-002"
                else:
                    stage_assigned = assigned_officer_id or "OFF-003"
                started_at = format_iso_timestamp(submitted_date, "10:00:00")
                completed_at = format_iso_timestamp(last_updated_date, "10:00:00")
                stage_remarks = "Stage completed successfully."

        elif overall_status == "Rejected":
            if s_order < current_stage_order:
                stage_status = "Completed"
                stage_assigned = "OFF-001" if s_order > 1 else None
                started_at = submitted_iso
                completed_at = last_updated_iso
                stage_remarks = "Stage completed."
            elif s_order == current_stage_order:
                stage_status = "Rejected"
                stage_assigned = assigned_officer_id
                started_at = last_updated_iso
                completed_at = last_updated_iso
                stage_remarks = remarks or "Application rejected."
            else:
                stage_status = "Pending"
                stage_assigned = None
                started_at = None
                completed_at = None
                stage_remarks = None

        elif s_order < current_stage_order:
            # Prior stages completed
            if s_order == 1:
                stage_status = "Completed"
                stage_assigned = None
                started_at = submitted_iso
                completed_at = submitted_iso
                stage_remarks = "Application submitted successfully."
            elif s_order == 2:
                stage_status = "Completed"
                stage_assigned = "OFF-001"
                started_at = format_iso_timestamp(submitted_date, "11:00:00")
                completed_at = format_iso_timestamp(last_updated_date, "15:00:00")
                stage_remarks = "Documents verified successfully."
            elif s_order == 3:
                stage_status = "Completed"
                stage_assigned = assigned_officer_id or "OFF-002"
                started_at = format_iso_timestamp(submitted_date, "11:00:00")
                completed_at = format_iso_timestamp(last_updated_date, "16:00:00")
                stage_remarks = "Officer verification completed."
            else:
                stage_status = "Completed"
                stage_assigned = assigned_officer_id
                started_at = format_iso_timestamp(submitted_date, "11:00:00")
                completed_at = format_iso_timestamp(last_updated_date, "16:00:00")
                stage_remarks = "Stage completed."

        elif s_order == current_stage_order:
            # Current stage
            if s_name == "Application Submitted":
                stage_status = "Completed"
                stage_assigned = None
                started_at = submitted_iso
                completed_at = submitted_iso
                stage_remarks = remarks or "Application submitted successfully."
            else:
                stage_status = "In Progress"
                stage_assigned = assigned_officer_id
                started_at = last_updated_iso
                completed_at = None
                stage_remarks = remarks

        else:
            # Future stages are Pending
            stage_status = "Pending"
            stage_assigned = None
            started_at = None
            completed_at = None
            stage_remarks = None

        stages.append({
            "stage_id": s_id,
            "stage_name": s_name,
            "stage_order": s_order,
            "status": stage_status,
            "assigned_to": stage_assigned,
            "started_at": started_at,
            "completed_at": completed_at,
            "remarks": stage_remarks,
        })

    return {
        "application_id": app_id,
        "current_stage": current_stage_name,
        "overall_status": overall_status,
        "last_updated": last_updated_iso,
        "stages": stages,
    }


def plan_initialization():
    """
    Reads Firestore, compares applications vs workflow_history,
    and returns:
      - existing_app_ids: set of application_ids with existing workflows
      - to_create: list of dict records to create
    """
    apps = get_collection_documents(APPLICATION_COLLECTION)
    existing_workflows = get_collection_documents(WORKFLOW_COLLECTION)

    existing_workflow_app_ids = {
        w.get("application_id")
        for w in existing_workflows
        if w.get("application_id")
    }

    to_create = []
    already_present = []

    # Sort apps by application_id for deterministic output
    sorted_apps = sorted(apps, key=lambda a: a.get("application_id", ""))

    for app in sorted_apps:
        app_id = app.get("application_id")
        if not app_id:
            continue

        if app_id in existing_workflow_app_ids:
            already_present.append(app_id)
        else:
            record = build_workflow_record(app)
            to_create.append(record)

    return already_present, to_create


def execute_initialization(to_create: list[dict[str, Any]]):
    """
    Safely writes missing workflow records to Firestore using application_id as doc ID.
    Strictly checks that the document does not already exist before writing.
    """
    for record in to_create:
        app_id = record["application_id"]
        doc_ref = db.collection(WORKFLOW_COLLECTION).document(app_id)
        
        # Double check existence
        if doc_ref.get().exists:
            print(f"[SKIP] Document {app_id} already exists in {WORKFLOW_COLLECTION}. Not overwriting.")
            continue

        doc_ref.set(record)
        print(f"[CREATED] {WORKFLOW_COLLECTION}/{app_id}")


def verify_workflows(expected_ids: list[str]):
    """
    Verifies that workflow records exist for expected application IDs.
    """
    print("\n--- Verification ---")
    all_ok = True
    for app_id in expected_ids:
        docs = list(db.collection(WORKFLOW_COLLECTION).where("application_id", "==", app_id).limit(1).stream())
        if docs:
            w_data = docs[0].to_dict()
            print(f"{app_id} → workflow exists (current_stage: '{w_data.get('current_stage')}', status: '{w_data.get('overall_status')}', stages: {len(w_data.get('stages', []))})")
        else:
            print(f"{app_id} → FAILED: workflow missing!")
            all_ok = False
    return all_ok


def main():
    parser = argparse.ArgumentParser(description="Initialize missing workflow_history records.")
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Actually apply changes to Firestore. If omitted, performs a dry-run.",
    )
    args = parser.parse_args()

    print("=== TrackGov AI - Workflow History Initializer ===\n")
    already_present, to_create = plan_initialization()

    print(f"Found {len(already_present)} applications with existing workflows:")
    for app_id in already_present:
        print(f"  - {app_id} (PROTECTED - will NOT be modified)")

    print(f"\nFound {len(to_create)} applications missing workflow_history:")
    for rec in to_create:
        print(f"  - {rec['application_id']}")

    print("\n" + "=" * 50)
    print("PLANNED RECORDS TO BE CREATED:")
    print("=" * 50)
    print(json.dumps(to_create, indent=2))
    print("=" * 50)

    if not args.apply:
        print("\n[DRY RUN] No changes were made to Firestore.")
        print("To apply these changes after approval, run:")
        print("  python backend/scripts/init_missing_workflows.py --apply")
        return

    print("\n[APPLYING] Writing records to Firestore...")
    execute_initialization(to_create)

    expected_ids = ["INC-2026-002", "INC-2026-003", "INC-2026-004"]
    verify_workflows(expected_ids)


if __name__ == "__main__":
    main()
