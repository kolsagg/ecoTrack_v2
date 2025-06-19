from pydantic import BaseModel, EmailStr
from typing import Optional

class DeviceInfo(BaseModel):
    device_id: str
    device_type: str  # 'ios', 'android', 'web'
    device_name: Optional[str] = None
    user_agent: Optional[str] = None

class UserSignUp(BaseModel):
    email: EmailStr
    password: str
    first_name: str
    last_name: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str
    remember_me: bool = False
    device_info: Optional[DeviceInfo] = None 