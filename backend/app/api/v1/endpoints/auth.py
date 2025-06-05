from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from app.core.auth import Auth
from app.core.config import settings
from typing import Dict

router = APIRouter()

class DeleteAccountRequest(BaseModel):
    password: str

@router.delete("/delete-account", response_model=Dict[str, str])
async def delete_account(
    request: DeleteAccountRequest,
    auth: Auth = Depends(Auth)
) -> Dict[str, str]:
    """
    Delete user account and all associated data.
    Requires password verification for security.
    """
    return await auth.delete_account(request.password) 