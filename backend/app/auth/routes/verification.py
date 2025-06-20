from fastapi import APIRouter, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
import os

router = APIRouter()

# Templates directory
templates_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "templates")
templates = Jinja2Templates(directory=templates_dir)

@router.get("/verify-email", response_class=HTMLResponse)
async def email_verification_page(request: Request):
    """
    Email doğrulama sayfasını göster.
    Supabase'den gelen callback URL'i için kullanılır.
    """
    return templates.TemplateResponse("email_confirmation.html", {"request": request})

@router.get("/auth/confirm", response_class=HTMLResponse)
async def auth_confirm_page(request: Request):
    """
    Email doğrulama callback endpoint'i.
    Supabase auth redirect URL'i olarak kullanılır.
    """
    return templates.TemplateResponse("email_confirmation.html", {"request": request}) 