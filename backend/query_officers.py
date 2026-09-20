import sys
from app.services.firestore_service import get_collection_documents

officers = get_collection_documents('officers')
for o in officers:
    print(f"officer_id: {o.get('officer_id')}, username: {o.get('username')}, password_exists: {'password' in o}")
