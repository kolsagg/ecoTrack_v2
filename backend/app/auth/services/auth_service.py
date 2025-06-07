from typing import Dict, Any, Optional
from fastapi import HTTPException, status
from app.core.config import settings
from app.auth.schemas.requests import UserSignUp, UserLogin

class AuthService:
    def __init__(self):
        self.client = settings.supabase

    async def sign_up(self, user_data: UserSignUp) -> Dict[str, Any]:
        """
        Register a new user with Supabase Auth and create user profile.
        """
        try:
            # Register user with Supabase Auth including metadata
            auth_response = self.client.auth.sign_up({
                "email": user_data.email,
                "password": user_data.password,
                "options": {
                    "data": {
                        "first_name": user_data.first_name,
                        "last_name": user_data.last_name
                    }
                }
            })

            if not auth_response.user:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Failed to create user account"
                )

            return {
                "message": "User registered successfully. Please check your email for verification.",
                "user": {
                    "id": auth_response.user.id,
                    "email": user_data.email,
                    "first_name": user_data.first_name,
                    "last_name": user_data.last_name
                }
            }

        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(e)
            )
        
    async def login(self, credentials: UserLogin) -> Dict[str, Any]:
        """
        Login user with email and password.
        """
        try:
            auth_response = self.client.auth.sign_in_with_password({
                "email": credentials.email,
                "password": credentials.password
            })

            if not auth_response.user:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid credentials"
                )

            # Get user profile
            profile_response = self.client.table("users").select("*").eq("id", auth_response.user.id).execute()

            if not profile_response.data:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="User profile not found"
                )

            return {
                "access_token": auth_response.session.access_token,
                "token_type": "bearer",
                "user": profile_response.data[0]
            }

        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=str(e)
            )

    async def verify_token(self, token: str) -> Optional[Dict[str, Any]]:
        """
        Verify JWT token and return user data.
        """
        try:
            user = self.client.auth.get_user(token)
            return user.dict() if user else None
        except Exception:
            return None

# Create global auth service instance
auth_service = AuthService() 