from typing import Dict, Any
from fastapi import HTTPException, status
from app.core.config import settings

class AccountService:
    def __init__(self):
        self.client = settings.supabase

    async def delete_account(self, password: str) -> Dict[str, str]:
        """
        Delete user account and all associated data.
        Uses service role key for secure deletion.
        """
        try:
            # Get current session
            session = self.client.auth.get_session()
            if not session:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="No active session"
                )

            # Verify password before deletion
            try:
                self.client.auth.sign_in_with_password({
                    "email": session.user.email,
                    "password": password
                })
            except Exception:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid password"
                )

            user_id = session.user.id

            # Create a new Supabase client with service role key
            admin_client = settings.supabase_admin

            try:
                # 1. First delete user data from public tables using service role
                # This bypasses RLS policies
                admin_client.from_("users").delete().eq("id", user_id).execute()
                
                # Add more delete operations for other tables if needed
                # Example:
                # admin_client.from_("user_preferences").delete().eq("user_id", user_id).execute()

                # 2. Delete any storage objects
                buckets = admin_client.storage.list_buckets()
                for bucket in buckets:
                    try:
                        objects = admin_client.storage.from_(bucket.name).list()
                        for obj in objects:
                            if obj.owner == user_id:
                                admin_client.storage.from_(bucket.name).remove([obj.name])
                    except Exception as e:
                        print(f"Error cleaning up storage in bucket {bucket.name}: {str(e)}")

                # 3. Finally delete the user from auth.users
                admin_client.auth.admin.delete_user(user_id)

                return {"message": "Account deleted successfully"}
            except Exception as e:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Failed to delete account: {str(e)}"
                )

        except Exception as e:
            if "Invalid password" not in str(e):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=str(e)
                )
            raise

# Create global account service instance
account_service = AccountService() 