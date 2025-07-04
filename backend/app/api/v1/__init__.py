from fastapi import APIRouter
from app.auth import auth_router

router = APIRouter()
router.include_router(auth_router)
