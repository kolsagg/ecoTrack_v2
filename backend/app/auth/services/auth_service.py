"""
Authentication service module for handling user authentication operations.

This module provides the AuthService class which handles user sign up, login,
logout, token management, and remember me functionality using Supabase Auth.
"""
import hashlib
import secrets
from datetime import datetime, timedelta
from typing import Dict, Any, Optional

from fastapi import HTTPException, status, Request

from app.core.config import settings
from app.auth.schemas.requests import UserSignUp, UserLogin

class AuthService:
    """
    Authentication service for handling user authentication operations.
    
    This service provides methods for user registration, login, logout,
    token management, and remember me functionality using Supabase Auth.
    """
    def __init__(self):
        self.client = settings.supabase
        self.admin_client = settings.supabase_admin

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
                "message": (
                    "User registered successfully. "
                    "Please check your email for verification."
                ),
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
            ) from e

    async def login(
        self,
        credentials: UserLogin,
        request: Optional[Request] = None
    ) -> Dict[str, Any]:
        """
        Login user with email and password, with remember me support.
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
            profile_response = (
                self.client.table("users")
                .select("*")
                .eq("id", auth_response.user.id)
                .execute()
            )

            if not profile_response.data:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="User profile not found"
                )

            user_data = profile_response.data[0]
            response_data = {
                "access_token": auth_response.session.access_token,  # type: ignore
                "refresh_token": auth_response.session.refresh_token,  # type: ignore
                "token_type": "bearer",
                "expires_in": 3600,  # 1 hour for regular access token
                "user": user_data
            }

            # Handle remember me functionality
            if credentials.remember_me and credentials.device_info:
                remember_token = await self._create_remember_me_token(
                    user_id=auth_response.user.id,
                    device_info=credentials.device_info,
                    request=request
                )
                response_data["remember_token"] = remember_token
                response_data["remember_expires_in"] = 30 * 24 * 3600  # 30 days

            # Register/update device if device_info provided
            if credentials.device_info:
                await self._register_or_update_device(
                    user_id=auth_response.user.id,
                    device_info=credentials.device_info
                )

            return response_data

        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=str(e)
            ) from e

    async def refresh_token(self, refresh_token: str) -> Dict[str, Any]:
        """
        Refresh access token using refresh token.
        """
        try:
            auth_response = self.client.auth.refresh_session(refresh_token)

            if not auth_response.session:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid refresh token"
                )

            return {
                "access_token": auth_response.session.access_token,
                "refresh_token": auth_response.session.refresh_token,
                "token_type": "bearer",
                "expires_in": 3600
            }

        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=str(e)
            ) from e

    async def login_with_remember_token(
        self,
        remember_token: str,
        device_id: str
    ) -> Dict[str, Any]:
        """
        Login user using remember me token.
        """
        try:
            # Hash the provided token to compare with stored hash
            token_hash = hashlib.sha256(remember_token.encode()).hexdigest()

            # Find and validate remember me token
            token_response = self.admin_client.table("remember_me_tokens").select(
                "*, users(*)"
            ).eq("token_hash", token_hash
            ).eq("device_id", device_id
            ).eq("is_active", True
            ).execute()

            if not token_response.data:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid remember me token"
                )

            token_data = token_response.data[0]
                        # Check if token is expired
            expires_at = datetime.fromisoformat(token_data["expires_at"].replace('Z', '+00:00'))
            if expires_at < datetime.now(expires_at.tzinfo):
                # Clean up expired token
                await self._cleanup_remember_token(token_data["id"])
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Remember me token expired"
                )

            # Update last used time
            self.admin_client.table("remember_me_tokens").update({
                "last_used_at": "now()"
            }).eq("id", token_data["id"]).execute()

            # Get fresh user profile
            user_id = token_data["user_id"]
            profile_response = (
                self.admin_client.table("users")
                .select("*")
                .eq("id", user_id)
                .execute()
            )

            if not profile_response.data:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="User profile not found"
                )

            return {
                "message": "Login successful with remember me token",
                "user": profile_response.data[0],
                "requires_new_session": True,
                "user_id": user_id
            }

        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=str(e)
            ) from e

    async def logout(
        self,
        user_id: str,
        device_id: Optional[str] = None,
        logout_all_devices: bool = False
    ) -> Dict[str, str]:
        """
        Logout user and cleanup remember me tokens and device status.
        """
        try:
            # Logout from Supabase
            self.client.auth.sign_out()

            if logout_all_devices:
                # Remove all remember me tokens for user
                (
                    self.admin_client.table("remember_me_tokens")
                    .delete()
                    .eq("user_id", user_id)
                    .execute()
                )

                # Deactivate all devices for user
                self.admin_client.table("user_devices").update({
                    "is_active": False
                }).eq("user_id", user_id).execute()

            elif device_id:
                # Remove remember me token for specific device
                (
                    self.admin_client.table("remember_me_tokens")
                    .delete()
                    .eq("user_id", user_id)
                    .eq("device_id", device_id)
                    .execute()
                )

                # Deactivate specific device
                self.admin_client.table("user_devices").update({
                    "is_active": False
                }).eq("user_id", user_id).eq("device_id", device_id).execute()

            return {"message": "Logout successful"}

        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(e)
            ) from e

    async def verify_token(self, token: str) -> Optional[Dict[str, Any]]:
        """
        Verify JWT token and return user data.
        """
        try:
            user = self.client.auth.get_user(token)
            return user.dict() if user else None
        except (ValueError, AttributeError, ConnectionError):
            return None

    async def _create_remember_me_token(
        self,
        user_id: str,
        device_info,
        request: Optional[Request] = None
    ) -> str:
        """
        Create a remember me token for the user and device.
        Deactivate any existing active tokens for the same device from other users.
        """
        try:
            # Generate secure random token
            remember_token = secrets.token_urlsafe(32)
            token_hash = hashlib.sha256(remember_token.encode()).hexdigest()

            # Set expiration to 30 days from now
            expires_at = datetime.utcnow() + timedelta(days=30)

            # Get IP address from request
            ip_address = None
            if request:
                ip_address = request.client.host if request.client else None

            # IMPORTANT: Deactivate any existing active tokens for this device from OTHER users
            # This ensures only one user can have an active remember me token per device
            self.admin_client.table("remember_me_tokens").update({
                "is_active": False
            }).eq("device_id", device_info.device_id
            ).neq("user_id", user_id
            ).eq("is_active", True
            ).execute()

            # Store token in database (upsert - update if exists, insert if not)
            token_data = {
                "user_id": user_id,
                "device_id": device_info.device_id,
                "token_hash": token_hash,
                "expires_at": expires_at.isoformat(),
                "user_agent": device_info.user_agent,
                "ip_address": ip_address,
                "is_active": True
            }

            # First try to update existing token for this user+device
            existing_token = (
                self.admin_client.table("remember_me_tokens")
                .select("id")
                .eq("user_id", user_id)
                .eq("device_id", device_info.device_id)
                .execute()
            )

            if existing_token.data:
                # Update existing token
                (
                    self.admin_client.table("remember_me_tokens")
                    .update(token_data)
                    .eq("id", existing_token.data[0]["id"])
                    .execute()
                )
            else:
                # Insert new token
                self.admin_client.table("remember_me_tokens").insert(token_data).execute()

            return remember_token

        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to create remember me token: {str(e)}"
            ) from e

    async def _register_or_update_device(self, user_id: str, device_info):
        """
        Register or update device information.
        Deactivate any existing active devices for the same device from other users.
        """
        try:
            # IMPORTANT: Deactivate any existing active devices for this device from OTHER users
            # This ensures only one user can have an active device registration per device
            self.admin_client.table("user_devices").update({
                "is_active": False
            }).eq("device_id", device_info.device_id
            ).neq("user_id", user_id
            ).eq("is_active", True
            ).execute()

            device_data = {
                "user_id": user_id,
                "device_id": device_info.device_id,
                "device_type": device_info.device_type,
                "device_name": device_info.device_name,
                "is_active": True,
                "last_used_at": "now()"
            }

            # Check if device already exists
            existing_device = (
                self.admin_client.table("user_devices")
                .select("id")
                .eq("user_id", user_id)
                .eq("device_id", device_info.device_id)
                .execute()
            )

            if existing_device.data:
                # Update existing device
                (
                    self.admin_client.table("user_devices")
                    .update(device_data)
                    .eq("id", existing_device.data[0]["id"])
                    .execute()
                )
            else:
                # Insert new device
                device_data["fcm_token"] = ""  # Will be updated later when FCM token is available
                self.admin_client.table("user_devices").insert(device_data).execute()

        except (ValueError, ConnectionError, AttributeError) as e:
            # Log error but don't fail the login process
            print(f"Error registering device: {e}")

    async def _cleanup_remember_token(self, token_id: str):
        """
        Clean up expired or invalid remember me token.
        """
        try:
            self.admin_client.table("remember_me_tokens").delete().eq("id", token_id).execute()
        except (ValueError, ConnectionError, AttributeError) as e:
            print(f"Error cleaning up remember token: {e}")

# Create global auth service instance
auth_service = AuthService()
