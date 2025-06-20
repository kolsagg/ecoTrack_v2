from fastapi import APIRouter, Depends
from typing import Dict, Any
from app.auth.dependencies import require_admin

router = APIRouter()

@router.get("/check-permissions")
async def check_admin_permissions(
    current_user: Dict[str, Any] = Depends(require_admin)
) -> Dict[str, Any]:
    """
    Check admin permissions endpoint.
    
    This endpoint is only accessible by users with admin role.
    Admin role is checked from the raw_app_meta_data {"role": "admin"} 
    field in the auth.users table.
    
    Returns:
        Dict: Admin user information and permission status
    """
    return {
        "message": "Admin permissions confirmed",
        "is_admin": True,
        "user_id": current_user.get("id"),
        "email": current_user.get("email"),
        "admin_metadata": {
            "app_metadata": current_user.get("app_metadata", {}),
            "user_metadata": current_user.get("user_metadata", {})
        }
    } 