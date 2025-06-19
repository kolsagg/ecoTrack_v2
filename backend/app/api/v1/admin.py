from fastapi import APIRouter, Depends
from typing import Dict, Any
from app.auth.dependencies import require_admin

router = APIRouter()

@router.get("/check-permissions")
async def check_admin_permissions(
    current_user: Dict[str, Any] = Depends(require_admin)
) -> Dict[str, Any]:
    """
    Admin yetkilerini kontrol eden endpoint.
    
    Bu endpoint sadece admin rolüne sahip kullanıcılar tarafından erişilebilir.
    Admin rolü auth.users tablosundaki raw_app_meta_data {"role": "admin"} 
    alanından kontrol edilir.
    
    Returns:
        Dict: Admin kullanıcı bilgileri ve yetki durumu
    """
    return {
        "message": "Admin yetkileriniz onaylandı",
        "is_admin": True,
        "user_id": current_user.get("id"),
        "email": current_user.get("email"),
        "admin_metadata": {
            "app_metadata": current_user.get("app_metadata", {}),
            "user_metadata": current_user.get("user_metadata", {})
        }
    } 