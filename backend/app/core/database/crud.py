from typing import Any, Dict, List, Optional, TypeVar, Generic
from app.core.config import settings

T = TypeVar('T')

class CRUDBase(Generic[T]):
    """
    Base class for CRUD operations.
    """
    def __init__(self, table_name: str):
        self.table_name = table_name
        self.client = settings.supabase

    async def get(self, id: str) -> Optional[Dict[str, Any]]:
        """
        Get a record by ID.
        """
        try:
            response = self.client.table(self.table_name).select("*").eq("id", id).execute()
            return response.data[0] if response.data else None
        except Exception as e:
            print(f"Error getting {self.table_name} by ID: {e}")
            return None

    async def get_multi(
        self,
        *,
        skip: int = 0,
        limit: int = 100,
        filters: Optional[Dict[str, Any]] = None
    ) -> List[Dict[str, Any]]:
        """
        Get multiple records with pagination and filtering.
        """
        try:
            query = self.client.table(self.table_name).select("*")
            
            if filters:
                for key, value in filters.items():
                    query = query.eq(key, value)
            
            response = query.range(skip, skip + limit - 1).execute()
            return response.data
        except Exception as e:
            print(f"Error getting multiple {self.table_name}: {e}")
            return []

    async def create(self, data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """
        Create a new record.
        """
        try:
            response = self.client.table(self.table_name).insert(data).execute()
            return response.data[0] if response.data else None
        except Exception as e:
            print(f"Error creating {self.table_name}: {e}")
            return None

    async def update(self, id: str, data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """
        Update a record by ID.
        """
        try:
            response = self.client.table(self.table_name).update(data).eq("id", id).execute()
            return response.data[0] if response.data else None
        except Exception as e:
            print(f"Error updating {self.table_name}: {e}")
            return None

    async def delete(self, id: str) -> bool:
        """
        Delete a record by ID.
        """
        try:
            response = self.client.table(self.table_name).delete().eq("id", id).execute()
            return bool(response.data)
        except Exception as e:
            print(f"Error deleting {self.table_name}: {e}")
            return False 