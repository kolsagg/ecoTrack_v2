from fastapi import APIRouter, Depends, HTTPException, status
from typing import Dict, Any
from app.auth.services.auth_service import auth_service
from app.auth.schemas.requests import UserSignUp

router = APIRouter()

@router.post("/register", response_model=Dict[str, Any])
async def register(user_data: UserSignUp) -> Dict[str, Any]:
    """
    Register a new user.
    """
    return await auth_service.sign_up(user_data) 