from fastapi import HTTPException, status, Depends
from typing import List, Optional
import logging
from app.core.config import settings
from app.core.auth import get_current_user

logger = logging.getLogger(__name__)

class Permission:
    """
    İzin sabitleri
    """
    # Kullanıcı izinleri
    READ_OWN_DATA = "read_own_data"
    WRITE_OWN_DATA = "write_own_data"
    DELETE_OWN_DATA = "delete_own_data"
    
    # Admin izinleri
    READ_ALL_DATA = "read_all_data"
    WRITE_ALL_DATA = "write_all_data"
    DELETE_ALL_DATA = "delete_all_data"
    MANAGE_USERS = "manage_users"
    MANAGE_MERCHANTS = "manage_merchants"
    VIEW_SYSTEM_METRICS = "view_system_metrics"
    
    # Merchant izinleri
    MANAGE_OWN_MERCHANT = "manage_own_merchant"
    SEND_WEBHOOKS = "send_webhooks"

class Role:
    """
    Rol sabitleri
    """
    USER = "user"
    ADMIN = "admin"
    MERCHANT = "merchant"
    SYSTEM = "system"

# Rol-izin eşlemeleri
ROLE_PERMISSIONS = {
    Role.USER: [
        Permission.READ_OWN_DATA,
        Permission.WRITE_OWN_DATA,
        Permission.DELETE_OWN_DATA
    ],
    Role.ADMIN: [
        Permission.READ_OWN_DATA,
        Permission.WRITE_OWN_DATA,
        Permission.DELETE_OWN_DATA,
        Permission.READ_ALL_DATA,
        Permission.WRITE_ALL_DATA,
        Permission.DELETE_ALL_DATA,
        Permission.MANAGE_USERS,
        Permission.MANAGE_MERCHANTS,
        Permission.VIEW_SYSTEM_METRICS
    ],
    Role.MERCHANT: [
        Permission.READ_OWN_DATA,
        Permission.MANAGE_OWN_MERCHANT,
        Permission.SEND_WEBHOOKS
    ],
    Role.SYSTEM: [
        Permission.SEND_WEBHOOKS,
        Permission.VIEW_SYSTEM_METRICS
    ]
}

def get_user_role(user) -> str:
    """
    Kullanıcının rolünü belirle
    """
    try:
        # Supabase user metadata'sından rol bilgisini al
        if hasattr(user, 'user_metadata') and user.user_metadata:
            return user.user_metadata.get('role', Role.USER)
        
        # Varsayılan olarak user rolü
        return Role.USER
        
    except Exception as e:
        logger.warning(f"Error getting user role: {e}")
        return Role.USER

def get_user_permissions(user) -> List[str]:
    """
    Kullanıcının izinlerini al
    """
    role = get_user_role(user)
    return ROLE_PERMISSIONS.get(role, ROLE_PERMISSIONS[Role.USER])

def has_permission(user, required_permission: str) -> bool:
    """
    Kullanıcının belirli bir izni olup olmadığını kontrol et
    """
    user_permissions = get_user_permissions(user)
    return required_permission in user_permissions

def require_permission(required_permission: str):
    """
    Belirli bir izin gerektiren decorator
    """
    def permission_dependency(current_user = Depends(get_current_user)):
        if not has_permission(current_user, required_permission):
            logger.warning(
                f"Permission denied: User {getattr(current_user, 'id', 'unknown')} "
                f"lacks permission {required_permission}"
            )
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Insufficient permissions. Required: {required_permission}"
            )
        return current_user
    
    return permission_dependency

def require_role(required_role: str):
    """
    Belirli bir rol gerektiren decorator
    """
    def role_dependency(current_user = Depends(get_current_user)):
        user_role = get_user_role(current_user)
        if user_role != required_role:
            logger.warning(
                f"Role access denied: User {getattr(current_user, 'id', 'unknown')} "
                f"has role {user_role}, required {required_role}"
            )
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access denied. Required role: {required_role}"
            )
        return current_user
    
    return role_dependency

def require_admin():
    """
    Admin rolü gerektiren dependency
    """
    return require_role(Role.ADMIN)

def require_merchant():
    """
    Merchant rolü gerektiren dependency
    """
    return require_role(Role.MERCHANT)

def check_resource_ownership(user, resource_user_id: str) -> bool:
    """
    Kullanıcının kaynağa sahip olup olmadığını kontrol et
    """
    user_id = getattr(user, 'id', None)
    if not user_id:
        return False
    
    # Admin her şeye erişebilir
    if has_permission(user, Permission.READ_ALL_DATA):
        return True
    
    # Kaynak sahibi erişebilir
    return str(user_id) == str(resource_user_id)

def require_resource_ownership(resource_user_id: str):
    """
    Kaynak sahipliği gerektiren dependency
    """
    def ownership_dependency(current_user = Depends(get_current_user)):
        if not check_resource_ownership(current_user, resource_user_id):
            logger.warning(
                f"Resource access denied: User {getattr(current_user, 'id', 'unknown')} "
                f"attempted to access resource owned by {resource_user_id}"
            )
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied. You can only access your own resources."
            )
        return current_user
    
    return ownership_dependency

def validate_api_key_permission(api_key: str, required_permission: str) -> bool:
    """
    API anahtarının belirli bir izni olup olmadığını kontrol et
    """
    try:
        # Merchant API anahtarı kontrolü
        if api_key.startswith(settings.MERCHANT_API_KEY_PREFIX):
            # Merchant API anahtarları sadece webhook gönderme izni var
            return required_permission in [Permission.SEND_WEBHOOKS]
        
        return False
        
    except Exception as e:
        logger.error(f"Error validating API key permission: {e}")
        return False

def log_authorization_event(user, action: str, resource: str, success: bool):
    """
    Yetkilendirme olayını logla
    """
    from app.core.logging_config import log_security_event
    
    user_id = getattr(user, 'id', 'unknown')
    user_role = get_user_role(user)
    
    log_security_event(
        "authorization_check",
        {
            "user_id": user_id,
            "user_role": user_role,
            "action": action,
            "resource": resource,
            "success": success
        }
    ) 