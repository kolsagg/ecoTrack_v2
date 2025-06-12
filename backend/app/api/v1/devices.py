from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
from pydantic import BaseModel
from app.db.supabase_client import get_authenticated_supabase_client
from app.core.logging_config import get_logger
from supabase import Client

router = APIRouter()
logger = get_logger(__name__)

class DeviceRegistrationRequest(BaseModel):
    device_id: str
    fcm_token: str
    device_type: str  # 'ios', 'android', 'web'
    device_name: Optional[str] = None
    app_version: Optional[str] = None
    os_version: Optional[str] = None

class DeviceResponse(BaseModel):
    id: str
    device_id: str
    device_type: str
    device_name: Optional[str]
    is_active: bool
    last_used_at: str
    created_at: str

@router.post("/register", response_model=dict)
async def register_device(
    device_data: DeviceRegistrationRequest,
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Kullanıcının cihazını ve FCM token'ını kaydet
    """
    try:
        # Mevcut kullanıcıyı al
        user = supabase.auth.get_user()
        if not user.user:
            raise HTTPException(status_code=401, detail="User not authenticated")
        
        user_id = user.user.id
        
        # Aynı device_id ile kayıt var mı kontrol et
        existing_device = supabase.table("user_devices").select("*").eq("user_id", user_id).eq("device_id", device_data.device_id).execute()
        
        if existing_device.data:
            # Mevcut cihazı güncelle
            update_data = {
                "fcm_token": device_data.fcm_token,
                "device_name": device_data.device_name,
                "app_version": device_data.app_version,
                "os_version": device_data.os_version,
                "is_active": True,
                "last_used_at": "now()"
            }
            
            result = supabase.table("user_devices").update(update_data).eq("id", existing_device.data[0]["id"]).execute()
            
            if result.data:
                logger.info(f"Device updated for user {user_id}: {device_data.device_id}")
                return {"message": "Device updated successfully", "device_id": device_data.device_id}
            else:
                raise HTTPException(status_code=500, detail="Failed to update device")
        else:
            # Yeni cihaz kaydı
            insert_data = {
                "user_id": user_id,
                "device_id": device_data.device_id,
                "fcm_token": device_data.fcm_token,
                "device_type": device_data.device_type,
                "device_name": device_data.device_name,
                "app_version": device_data.app_version,
                "os_version": device_data.os_version,
                "is_active": True
            }
            
            result = supabase.table("user_devices").insert(insert_data).execute()
            
            if result.data:
                logger.info(f"New device registered for user {user_id}: {device_data.device_id}")
                return {"message": "Device registered successfully", "device_id": device_data.device_id}
            else:
                raise HTTPException(status_code=500, detail="Failed to register device")
                
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error registering device: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

@router.get("/", response_model=List[DeviceResponse])
async def get_user_devices(
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Kullanıcının kayıtlı cihazlarını listele
    """
    try:
        user = supabase.auth.get_user()
        if not user.user:
            raise HTTPException(status_code=401, detail="User not authenticated")
        
        user_id = user.user.id
        
        result = supabase.table("user_devices").select("id, device_id, device_type, device_name, is_active, last_used_at, created_at").eq("user_id", user_id).order("last_used_at", desc=True).execute()
        
        return result.data
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting user devices: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

@router.put("/{device_id}/deactivate")
async def deactivate_device(
    device_id: str,
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Cihazı deaktif et (FCM token'ını geçersiz kıl)
    """
    try:
        user = supabase.auth.get_user()
        if not user.user:
            raise HTTPException(status_code=401, detail="User not authenticated")
        
        user_id = user.user.id
        
        result = supabase.table("user_devices").update({"is_active": False}).eq("user_id", user_id).eq("device_id", device_id).execute()
        
        if result.data:
            logger.info(f"Device deactivated for user {user_id}: {device_id}")
            return {"message": "Device deactivated successfully"}
        else:
            raise HTTPException(status_code=404, detail="Device not found")
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deactivating device: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

@router.delete("/{device_id}")
async def delete_device(
    device_id: str,
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Cihazı tamamen sil
    """
    try:
        user = supabase.auth.get_user()
        if not user.user:
            raise HTTPException(status_code=401, detail="User not authenticated")
        
        user_id = user.user.id
        
        result = supabase.table("user_devices").delete().eq("user_id", user_id).eq("device_id", device_id).execute()
        
        if result.data:
            logger.info(f"Device deleted for user {user_id}: {device_id}")
            return {"message": "Device deleted successfully"}
        else:
            raise HTTPException(status_code=404, detail="Device not found")
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting device: {e}")
        raise HTTPException(status_code=500, detail="Internal server error") 