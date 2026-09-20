from pathlib import Path
from typing import Any

import firebase_admin
from firebase_admin import credentials, firestore


# ---------------------------------------------------------
# Paths
# ---------------------------------------------------------

BASE_DIR = Path(__file__).resolve().parents[1]

CREDENTIALS_PATH = (
    BASE_DIR / "firebase-service-account.json"
)


# ---------------------------------------------------------
# Firebase Initialization
# ---------------------------------------------------------

if not firebase_admin._apps:
    cred = credentials.Certificate(
        str(CREDENTIALS_PATH)
    )

    firebase_admin.initialize_app(cred)


# ---------------------------------------------------------
# Firestore Client
# ---------------------------------------------------------

db = firestore.client()


# ---------------------------------------------------------
# Collection Helpers
# ---------------------------------------------------------

def get_collection_documents(
    collection_name: str,
) -> list[dict[str, Any]]:
    """
    Return all documents from a Firestore collection.
    """

    documents = []

    collection_ref = db.collection(
        collection_name
    )

    for document in collection_ref.stream():

        data = document.to_dict()

        if data is None:
            continue

        documents.append(data)

    return documents


def get_document_by_id(
    collection_name: str,
    document_id: str,
) -> dict[str, Any] | None:
    """
    Return one Firestore document by document ID.
    """

    document_ref = (
        db
        .collection(collection_name)
        .document(document_id)
    )

    document = document_ref.get()

    if not document.exists:
        return None

    return document.to_dict()


def get_document_by_field(
    collection_name: str,
    field_name: str,
    field_value: Any,
) -> dict[str, Any] | None:
    """
    Find one document using a field value.
    """

    query = (
        db
        .collection(collection_name)
        .where(
            filter=firestore.FieldFilter(
                field_name,
                "==",
                field_value,
            )
        )
        .limit(1)
    )

    documents = list(query.stream())

    if not documents:
        return None

    return documents[0].to_dict()


def get_documents_by_field(
    collection_name: str,
    field_name: str,
    field_value: Any,
) -> list[dict[str, Any]]:
    """
    Find all documents matching a field value.
    """

    query = (
        db
        .collection(collection_name)
        .where(
            filter=firestore.FieldFilter(
                field_name,
                "==",
                field_value,
            )
        )
    )

    return [
        document.to_dict()
        for document in query.stream()
    ]


def create_document(
    collection_name: str,
    document_id: str,
    data: dict[str, Any],
) -> None:
    """
    Create or replace a Firestore document.
    """

    (
        db
        .collection(collection_name)
        .document(document_id)
        .set(data)
    )


def update_document(
    collection_name: str,
    document_id: str,
    data: dict[str, Any],
) -> None:
    """
    Update fields in an existing Firestore document.
    """

    (
        db
        .collection(collection_name)
        .document(document_id)
        .update(data)
    )


def delete_document(
    collection_name: str,
    document_id: str,
) -> None:
    """
    Delete a Firestore document.
    """

    (
        db
        .collection(collection_name)
        .document(document_id)
        .delete()
    )


# ---------------------------------------------------------
# Connection Test
# ---------------------------------------------------------

if __name__ == "__main__":

    print(
        "Firestore connection successful!"
    )