from fastapi import APIRouter, Depends, HTTPException, status
from typing import Dict, Any, Optional
from app.auth.services.mfa_service import mfa_service
from app.core.auth import get_current_user
from pydantic import BaseModel

router = APIRouter()

class VerifyTOTPRequest(BaseModel):
    factor_id: str
    code: str

class DisableTOTPRequest(BaseModel):
    factor_id: Optional[str] = None
    code: str

@router.get("/mfa/status", response_model=Dict[str, Any])
async def get_mfa_status(current_user: dict = Depends(get_current_user)) -> Dict[str, Any]:
    """
    Get MFA status for the current user.
    """
    return await mfa_service.get_mfa_status(current_user)

@router.get("/mfa/factors", response_model=Dict[str, Any])
async def list_factors(current_user: dict = Depends(get_current_user)) -> Dict[str, Any]:
    """
    List all MFA factors for the current user.
    """
    return await mfa_service.list_mfa_factors(current_user)

@router.post("/mfa/totp/create", response_model=Dict[str, Any])
async def create_totp() -> Dict[str, Any]:
    """
    Create a new TOTP factor for MFA.
    """
    return await mfa_service.create_totp_factor()

@router.post("/mfa/totp/verify", response_model=Dict[str, str])
async def verify_totp(request: VerifyTOTPRequest) -> Dict[str, str]:
    """
    Verify a TOTP factor during enrollment.
    """
    return await mfa_service.verify_totp_factor(request.factor_id, request.code)

@router.post("/mfa/totp/challenge", response_model=Dict[str, Any])
async def challenge_totp(request: VerifyTOTPRequest) -> Dict[str, Any]:
    """
    Challenge a TOTP factor during login.
    """
    return await mfa_service.challenge_totp_factor(request.factor_id, request.code)

@router.post("/mfa/totp/disable", response_model=Dict[str, str])
async def disable_totp(request: DisableTOTPRequest) -> Dict[str, str]:
    """
    Disable TOTP factor for MFA.
    """
    return await mfa_service.disable_totp_factor(request.factor_id, request.code) 