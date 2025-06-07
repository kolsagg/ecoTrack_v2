from fastapi import APIRouter
from app.auth.routes import login, register, password, mfa, account

auth_router = APIRouter()

# Include all auth-related routers
auth_router.include_router(login.router, tags=["auth"])
auth_router.include_router(register.router, tags=["auth"])
auth_router.include_router(password.router, tags=["auth"])
auth_router.include_router(mfa.router, tags=["auth"])
auth_router.include_router(account.router, tags=["auth"]) 