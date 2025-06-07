from pydantic import BaseModel
from typing import Optional, List, Dict, Any

class UserProfile(BaseModel):
    id: str
    email: str
    first_name: str
    last_name: str

class AuthResponse(BaseModel):
    access_token: str
    token_type: str
    user: UserProfile

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