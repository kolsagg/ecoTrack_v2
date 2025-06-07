from fastapi import APIRouter, Depends, HTTPException, status
from typing import Dict
from app.auth.services.account_service import account_service
from pydantic import BaseModel

router = APIRouter()

class DeleteAccountRequest(BaseModel):
    password: str

@router.delete("/account", response_model=Dict[str, str])
async def delete_account(request: DeleteAccountRequest) -> Dict[str, str]:
    """
    Delete user account and all associated data.
    Requires password verification for security.
    """
    return await account_service.delete_account(request.password) 