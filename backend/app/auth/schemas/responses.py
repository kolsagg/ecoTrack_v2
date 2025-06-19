from pydantic import BaseModel
from typing import Optional, List, Dict, Any

class UserProfile(BaseModel):
    id: str
    email: str
    first_name: str
    last_name: str

class AuthResponse(BaseModel):
    access_token: str
    refresh_token: Optional[str] = None
    token_type: str
    expires_in: int = 3600
    user: UserProfile
    remember_token: Optional[str] = None
    remember_expires_in: Optional[int] = None

class RefreshResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str
    expires_in: int

class RememberMeLoginResponse(BaseModel):
    message: str
    user: UserProfile
    requires_new_session: bool
    user_id: str

class MessageResponse(BaseModel):
    message: str

class MFAStatus(BaseModel):
    is_enabled: bool
    factors: List[str]
    preferred_factor: Optional[str]

class TOTPFactor(BaseModel):
    id: str
    qr_code: str
    secret: str
    uri: str 