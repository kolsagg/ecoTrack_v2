from fastapi import APIRouter, Depends, BackgroundTasks
from typing import Dict, Any
from app.auth.dependencies import require_admin
from app.services.global_inflation_service import GlobalInflationService

router = APIRouter()

@router.post("/trigger-monthly-inflation-calculation", status_code=202)
async def trigger_monthly_inflation_calculation(
    background_tasks: BackgroundTasks,
    current_user: Dict[str, Any] = Depends(require_admin)
):
    """
    Triggers a background task to calculate and store monthly product inflation data.
    This calculates month-over-month price changes for all products.
    This is a non-blocking operation and only accessible by admins.
    """
    service = GlobalInflationService()
    background_tasks.add_task(service.calculate_and_store_monthly_inflation)
    return {"message": "Monthly inflation calculation has been started in the background."}

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