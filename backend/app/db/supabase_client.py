from supabase import Client, create_client
from app.core.config import settings
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

security = HTTPBearer()

def get_supabase_client() -> Client:
    """
    Get Supabase client instance
    """
    return settings.supabase

def get_supabase_admin_client() -> Client:
    """
    Get Supabase admin client instance with service role key
    """
    return settings.supabase_admin

def get_authenticated_supabase_client(
    credentials: HTTPAuthorizationCredentials = Depends(security)
) -> Client:
    """Get Supabase client with user's JWT token set for RLS"""
    # Create a new client instance for this request
    client = create_client(settings.SUPABASE_URL, settings.SUPABASE_KEY)

    # Set the user's JWT token for RLS
    token = credentials.credentials

    # Verify token first
    try:
        user_response = client.auth.get_user(token)
        if not user_response.user: # type: ignore
            raise HTTPException(status_code=401, detail="Invalid token")

        # Set the JWT token for RLS using PostgREST headers
        # This is the correct way to pass JWT for RLS in Supabase
        client.postgrest.auth(token)

        return client
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Authentication failed: {str(e)}") 