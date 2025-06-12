from fastapi import APIRouter
from app.auth import auth_router
from app.api.v1 import receipts, expenses, categories, merchants, webhooks, loyalty, reviews, devices
from app.api import ai_analysis, reporting

api_router = APIRouter()

# Include auth router
api_router.include_router(auth_router, prefix="/auth")

# Include business logic routers
api_router.include_router(receipts.router, prefix="/receipts", tags=["receipts"])
api_router.include_router(expenses.router, prefix="/expenses", tags=["expenses"])
api_router.include_router(categories.router, prefix="/categories", tags=["categories"]) 

# Include merchant integration routers
api_router.include_router(merchants.router, prefix="/merchants", tags=["merchants"])
api_router.include_router(webhooks.router, prefix="/webhooks", tags=["webhooks"])

# Include review system router
api_router.include_router(reviews.router, prefix="/reviews", tags=["reviews"])

# Include AI analysis router
api_router.include_router(ai_analysis.router, prefix="/ai", tags=["AI Analysis"])

# Include financial reporting router
api_router.include_router(reporting.router, prefix="/reports", tags=["Financial Reporting"])

# Include loyalty program router
api_router.include_router(loyalty.router, prefix="/loyalty", tags=["Loyalty Program"])

# Include device management router
api_router.include_router(devices.router, prefix="/devices", tags=["Device Management"]) 