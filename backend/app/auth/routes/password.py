from fastapi import APIRouter, Depends, HTTPException, status
from typing import Dict
from app.auth.services.password_service import password_service
from pydantic import BaseModel, EmailStr

router = APIRouter()

class ResetPasswordRequest(BaseModel):
    email: EmailStr

class ConfirmResetRequest(BaseModel):
    token: str
    new_password: str

@router.post("/reset-password", response_model=Dict[str, str])
async def reset_password(request: ResetPasswordRequest) -> Dict[str, str]:
    """
    Send password reset email.
    """
    return await password_service.reset_password(request.email)

@router.post("/reset-password/confirm", response_model=Dict[str, str])
async def confirm_reset(request: ConfirmResetRequest) -> Dict[str, str]:
    """
    Confirm password reset with token and new password.
    """
    return await password_service.confirm_password_reset(request.token, request.new_password) 