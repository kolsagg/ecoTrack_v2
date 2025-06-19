from fastapi import APIRouter, Depends, HTTPException, status, Request
from typing import Dict, Any
from pydantic import BaseModel
from app.auth.services.auth_service import auth_service
from app.auth.schemas.requests import UserLogin
from app.auth.schemas.responses import AuthResponse, RefreshResponse, RememberMeLoginResponse
from app.core.auth import get_current_user

router = APIRouter()

class RefreshTokenRequest(BaseModel):
    refresh_token: str

class RememberMeLoginRequest(BaseModel):
    remember_token: str
    device_id: str

class LogoutRequest(BaseModel):
    device_id: str = None
    logout_all_devices: bool = False

@router.post("/login", response_model=AuthResponse)
async def login(credentials: UserLogin, request: Request) -> Dict[str, Any]:
    """
    Login with email and password, with remember me support.
    """
    return await auth_service.login(credentials, request)

@router.post("/refresh", response_model=RefreshResponse)
async def refresh_token(token_request: RefreshTokenRequest) -> Dict[str, Any]:
    """
    Refresh access token using refresh token.
    """
    return await auth_service.refresh_token(token_request.refresh_token)

@router.post("/remember-me-login", response_model=RememberMeLoginResponse)
async def login_with_remember_me(remember_request: RememberMeLoginRequest) -> Dict[str, Any]:
    """
    Login using remember me token.
    """
    return await auth_service.login_with_remember_token(
        remember_request.remember_token,
        remember_request.device_id
    )

@router.post("/logout", response_model=Dict[str, str])
async def logout(
    logout_request: LogoutRequest,
    current_user: Dict[str, Any] = Depends(get_current_user)
) -> Dict[str, str]:
    """
    Logout user and cleanup remember me tokens.
    """
    return await auth_service.logout(
        user_id=current_user["id"],
        device_id=logout_request.device_id,
        logout_all_devices=logout_request.logout_all_devices
    ) 