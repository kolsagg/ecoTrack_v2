from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List

class UserSignUp(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)
    first_name: str = Field(min_length=2, max_length=50)
    last_name: str = Field(min_length=2, max_length=50)

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class PasswordReset(BaseModel):
    email: EmailStr

class PasswordResetConfirm(BaseModel):
    token: str
    new_password: str = Field(min_length=8)

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: dict

class AuthResponse(BaseModel):
    message: str
    data: Optional[dict] = None

class TOTPFactorCreate(BaseModel):
    qr_code: str
    secret: str

class TOTPFactorVerify(BaseModel):
    factor_id: Optional[str] = None
    code: str

class TOTPFactorChallenge(BaseModel):
    factor_id: Optional[str] = None
    code: str

class TOTPFactorDisable(BaseModel):
    factor_id: Optional[str] = None
    code: str
    reason: Optional[str] = None

class DeleteAccount(BaseModel):
    """
    Request schema for account deletion.
    Requires password confirmation for security.
    """
    password: str

class MFAStatus(BaseModel):
    """
    Response schema for MFA status.
    """
    is_enabled: bool
    factors: List[str] = []  # ["totp", "backup_codes"]
    preferred_factor: Optional[str] = None

class BackupCodes(BaseModel):
    """
    Response schema for backup codes.
    """
    codes: List[str]
    created_at: str
    remaining_codes: int 