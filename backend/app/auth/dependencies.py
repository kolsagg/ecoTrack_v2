from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from supabase import Client
from app.db.supabase_client import get_supabase_client
from app.core.config import settings
from typing import Dict, Any
import jwt

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
        
        # Check if this is a service role key (admin operations)
        if token == settings.SUPABASE_SERVICE_ROLE_KEY:
            # Service role key has admin privileges
            return {
                "id": "service-role",
                "email": "service@admin.com",
                "user_metadata": {"role": "admin"},
                "app_metadata": {"role": "admin", "is_admin": True}
            }
        
        # Try to decode JWT manually first (for custom tokens)
        try:
            # Get JWT secret from settings
            jwt_secret = getattr(settings, 'JWT_SECRET_KEY', None)
            if jwt_secret:
                decoded = jwt.decode(token, jwt_secret, algorithms=["HS256"])
                
                # Check if this is a valid Supabase JWT
                if decoded.get("iss") == "supabase":
                    return {
                        "id": decoded.get("sub"),
                        "email": decoded.get("email", ""),
                        "user_metadata": decoded.get("user_metadata", {}),
                        "app_metadata": decoded.get("app_metadata", {})
                    }
        except jwt.InvalidTokenError:
            pass  # Fall back to Supabase validation
        
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


async def get_current_active_user(
    current_user: Dict[str, Any] = Depends(get_current_user)
) -> Dict[str, Any]:
    """
    Get current active user (additional checks can be added here)
    """
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