from fastapi import APIRouter
from app.auth import auth_router
from app.api.v1 import receipts, expenses, categories

api_router = APIRouter()

# Include auth router
api_router.include_router(auth_router, prefix="/auth")

# Include business logic routers
api_router.include_router(receipts.router, prefix="/receipts", tags=["receipts"])
api_router.include_router(expenses.router, prefix="/expenses", tags=["expenses"])
api_router.include_router(categories.router, prefix="/categories", tags=["categories"]) 