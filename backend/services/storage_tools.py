"""
Storage Tools for Kisan AI agents using Google Cloud Storage
"""

from google.cloud import storage
from google.cloud import firestore
import uuid
import asyncio
from typing import Optional, Dict, Any
from datetime import datetime

from config.settings import settings


class StorageTools:
    """
    Storage tools for file uploads and data persistence
    """
    
    def __init__(self):
        """Initialize Storage Tools with GCP clients"""
        self.storage_client = storage.Client(project=settings.GCP_PROJECT_ID)
        self.firestore_client = firestore.Client(project=settings.GCP_PROJECT_ID)
        self.bucket_name = settings.UPLOAD_BUCKET
    
    async def upload_image(
        self, 
        image_data: bytes, 
        user_id: str, 
        file_extension: str = "jpg"
    ) -> Optional[str]:
        """
        Upload image to Cloud Storage and return public URL
        """
        try:
            # Generate unique filename
            image_id = str(uuid.uuid4())
            blob_name = f"images/{user_id}/{image_id}.{file_extension}"
            
            # Get bucket and create blob
            bucket = self.storage_client.bucket(self.bucket_name)
            blob = bucket.blob(blob_name)
            
            # Upload image
            blob.upload_from_string(
                image_data,
                content_type=f"image/{file_extension}"
            )
            
            # Make blob publicly readable
            blob.make_public()
            
            return blob.public_url
            
        except Exception as e:
            print(f"Image upload error: {str(e)}")
            return None
    
    async def save_conversation(
        self, 
        user_id: str, 
        conversation_data: Dict[str, Any]
    ) -> bool:
        """
        Save conversation to Firestore
        """
        try:
            # Create document reference
            doc_ref = self.firestore_client.collection('conversations').document()
            
            # Add metadata
            conversation_data.update({
                'user_id': user_id,
                'timestamp': datetime.now(),
                'conversation_id': doc_ref.id
            })
            
            # Save to Firestore
            doc_ref.set(conversation_data)
            
            return True
            
        except Exception as e:
            print(f"Conversation save error: {str(e)}")
            return False
    
    async def get_user_conversations(
        self, 
        user_id: str, 
        limit: int = 10
    ) -> list:
        """
        Get user's recent conversations from Firestore
        """
        try:
            # Query conversations
            conversations_ref = self.firestore_client.collection('conversations')
            query = conversations_ref.where('user_id', '==', user_id)\
                                   .order_by('timestamp', direction=firestore.Query.DESCENDING)\
                                   .limit(limit)
            
            conversations = []
            for doc in query.stream():
                conversation_data = doc.to_dict()
                conversation_data['id'] = doc.id
                conversations.append(conversation_data)
            
            return conversations
            
        except Exception as e:
            print(f"Conversation retrieval error: {str(e)}")
            return []
    
    async def save_user_context(
        self, 
        user_id: str, 
        context_data: Dict[str, Any]
    ) -> bool:
        """
        Save user context to Firestore
        """
        try:
            # Create/update user context document
            doc_ref = self.firestore_client.collection('user_contexts').document(user_id)
            
            # Add metadata
            context_data.update({
                'user_id': user_id,
                'last_updated': datetime.now()
            })
            
            # Save to Firestore
            doc_ref.set(context_data, merge=True)
            
            return True
            
        except Exception as e:
            print(f"Context save error: {str(e)}")
            return False
    
    async def get_user_context(self, user_id: str) -> Dict[str, Any]:
        """
        Get user context from Firestore
        """
        try:
            # Get user context document
            doc_ref = self.firestore_client.collection('user_contexts').document(user_id)
            doc = doc_ref.get()
            
            if doc.exists:
                return doc.to_dict()
            else:
                # Return default context
                return {
                    'location': 'Karnataka',
                    'language': 'kn',
                    'farming_type': 'mixed',
                    'land_size': 'small'
                }
                
        except Exception as e:
            print(f"Context retrieval error: {str(e)}")
            return {
                'location': 'Karnataka',
                'language': 'kn',
                'farming_type': 'mixed',
                'land_size': 'small'
            }
    
    async def delete_file(self, file_url: str) -> bool:
        """
        Delete file from Cloud Storage
        """
        try:
            # Extract blob name from URL
            blob_name = file_url.split(f"{self.bucket_name}/")[-1]
            
            # Get bucket and delete blob
            bucket = self.storage_client.bucket(self.bucket_name)
            blob = bucket.blob(blob_name)
            blob.delete()
            
            return True
            
        except Exception as e:
            print(f"File deletion error: {str(e)}")
            return False
    
    def get_bucket_info(self) -> Dict[str, Any]:
        """
        Get bucket information
        """
        try:
            bucket = self.storage_client.bucket(self.bucket_name)
            return {
                'name': bucket.name,
                'location': bucket.location,
                'storage_class': bucket.storage_class,
                'created': bucket.time_created
            }
        except Exception as e:
            print(f"Bucket info error: {str(e)}")
            return {}
