from pathlib import Path

import firebase_admin
from firebase_admin import credentials, firestore


# Get the backend folder path
BASE_DIR = Path(__file__).resolve().parents[2]

# Firebase service account file
CREDENTIALS_PATH = BASE_DIR / "firebase-service-account.json"


# Initialize Firebase only once
if not firebase_admin._apps:
    cred = credentials.Certificate(str(CREDENTIALS_PATH))
    firebase_admin.initialize_app(cred)


# Create Firestore client
db = firestore.client()


if __name__ == "__main__":
    print("Firestore connection successful!")

def get_document_by_id(collection_name: str, doc_id: str) -> dict | None:
    doc_ref = db.collection(collection_name).document(doc_id)
    doc = doc_ref.get()
    if doc.exists:
        return doc.to_dict()
    return None

def get_collection_documents(collection_name: str) -> list[dict]:
    docs = db.collection(collection_name).stream()
    return [doc.to_dict() for doc in docs]

def get_document_by_field(collection_name: str, field: str, value: any) -> dict | None:
    docs = db.collection(collection_name).where(field, "==", value).limit(1).stream()
    for doc in docs:
        return doc.to_dict()
    return None

def get_document_id_by_field(collection_name: str, field: str, value: any) -> str | None:
    docs = db.collection(collection_name).where(field, "==", value).limit(1).stream()
    for doc in docs:
        return doc.id
    return None

def get_documents_by_field(collection_name: str, field: str, value: any) -> list[dict]:
    docs = db.collection(collection_name).where(field, "==", value).stream()
    return [doc.to_dict() for doc in docs]

def create_document(collection_name: str, doc_id: str, data: dict) -> dict:
    db.collection(collection_name).document(doc_id).set(data)
    return data

def update_document(collection_name: str, doc_id: str, data: dict) -> dict | None:
    doc_ref = db.collection(collection_name).document(doc_id)
    if doc_ref.get().exists:
        doc_ref.update(data)
        return doc_ref.get().to_dict()
    return None

def delete_document(collection_name: str, doc_id: str) -> bool:
    doc_ref = db.collection(collection_name).document(doc_id)
    if doc_ref.get().exists:
        doc_ref.delete()
        return True
    return False