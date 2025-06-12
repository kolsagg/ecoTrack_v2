from fastapi import Depends, HTTPException, status, Header
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from supabase import Client
from app.db.supabase_client import get_supabase_client
import jwt
from typing import Dict, Any, Optional

security = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    supabase: Client = Depends(get_supabase_client)
) -> Dict[str, Any]:
    """
    Get current authenticated user from JWT token
    """
    try:
        token = credentials.credentials
        
        # Verify token with Supabase
        user_response = supabase.auth.get_user(token)
        
        if not user_response.user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid authentication credentials",
                headers={"WWW-Authenticate": "Bearer"},
            )
        
        user = user_response.user
        
        return {
            "id": user.id,
            "email": user.email,
            "user_metadata": user.user_metadata,
            "app_metadata": user.app_metadata
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )

async def get_optional_current_user(
    authorization: Optional[str] = Header(None),
    supabase: Client = Depends(get_supabase_client)
) -> Optional[Dict[str, Any]]:
    """
    Get current user if authenticated, otherwise return None
    """
    if not authorization or not authorization.startswith("Bearer "):
        return None
    
    try:
        token = authorization.split(" ")[1]
        user_response = supabase.auth.get_user(token)
        
        if not user_response.user:
            return None
        
        user = user_response.user
        
        return {
            "id": user.id,
            "email": user.email,
            "user_metadata": user.user_metadata,
            "app_metadata": user.app_metadata
        }
        
    except Exception:
        return None

async def get_current_active_user(
    current_user: Dict[str, Any] = Depends(get_current_user)
) -> Dict[str, Any]:
    """
    Get current active user (additional checks can be added here)
    """
    # Add any additional user validation logic here
    return current_user 

async def require_admin(
    current_user: Dict[str, Any] = Depends(get_current_user)
) -> Dict[str, Any]:
    """
    Require admin role for accessing endpoint
    
    Checks if the current user has admin privileges.
    Admin status is determined by app_metadata.role or user_metadata.role.
    """
    try:
        # Check app_metadata first (set by Supabase admin)
        app_metadata = current_user.get("app_metadata", {})
        user_metadata = current_user.get("user_metadata", {})
        
        # Check for admin role in app_metadata (preferred)
        if app_metadata.get("role") == "admin":
            return current_user
        
        # Fallback to user_metadata
        if user_metadata.get("role") == "admin":
            return current_user
        
        # Check for admin flag
        if app_metadata.get("is_admin") is True:
            return current_user
        
        if user_metadata.get("is_admin") is True:
            return current_user
        
        # No admin privileges found
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error checking admin privileges: {str(e)}"
        ) 