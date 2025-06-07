from fastapi import APIRouter, Depends, HTTPException, status
from typing import Dict, Any
from app.auth.services.auth_service import auth_service
from app.auth.schemas.requests import UserLogin

router = APIRouter()

@router.post("/login", response_model=Dict[str, Any])
async def login(credentials: UserLogin) -> Dict[str, Any]:
    """
    Login with email and password.
    """
    return await auth_service.login(credentials) 