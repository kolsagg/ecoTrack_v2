from typing import Optional, Dict, Any
from fastapi import HTTPException, status
from app.core.config import settings
from app.schemas.auth import UserSignUp, UserLogin

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

    async def reset_password(self, email: str) -> Dict[str, str]:
        """
        Send password reset email.
        """
        try:
            # Send password reset email with redirect URL
            self.client.auth.reset_password_email(
                email,
                {
                    "redirect_to": f"{settings.FRONTEND_URL}/auth/reset-password"
                }
            )
            return {"message": "Password reset email sent successfully"}
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
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

    async def confirm_password_reset(self, token: str, new_password: str) -> Dict[str, str]:
        """
        Confirm password reset with token and new password.
        """
        try:
            # Update user's password using the session from the reset token
            self.client.auth.update_user({
                "password": new_password
            })
            return {"message": "Password reset successfully"}
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(e)
            )

    async def get_authenticator_assurance_level(self) -> Dict[str, str]:
        """
        Get the current and next authenticator assurance level (AAL) for the user.
        This helps determine if MFA verification is needed.
        """
        try:
            session = self.client.auth.get_session()
            if not session:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="No active session"
                )

            aal_response = self.client.auth.mfa.get_authenticator_assurance_level()
            
            return {
                "current_level": aal_response.current_level,
                "next_level": aal_response.next_level,
                "needs_mfa": (
                    aal_response.next_level == "aal2" and 
                    aal_response.current_level != aal_response.next_level
                )
            }
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(e)
            )

    async def list_mfa_factors(self) -> Dict[str, Any]:
        """
        List all MFA factors for the current user.
        """
        try:
            session = self.client.auth.get_session()
            if not session:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="No active session"
                )

            factors_response = self.client.auth.mfa.list_factors()
            
            if not factors_response:
                return {
                    "totp": []
                }

            return {
                "totp": [
                    {
                        "id": f.id,
                        "friendly_name": f.friendly_name,
                        "factor_type": f.factor_type,
                        "status": f.status
                    }
                    for f in factors_response.all 
                    if f.factor_type == "totp"
                ]
            }
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(e)
            )

    async def create_totp_factor(self) -> Dict[str, Any]:
        """
        Create a new TOTP factor for MFA.
        """
        try:
            session = self.client.auth.get_session()
            if not session:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="No active session"
                )

            # Create a new TOTP factor
            factor = self.client.auth.mfa.enroll({
                "factor_type": "totp",
                "issuer": "EcoTrack",
                "friendly_name": "EcoTrack Authenticator"
            })

            return {
                "id": factor.id,
                "qr_code": factor.totp.qr_code,
                "secret": factor.totp.secret,
                "uri": factor.totp.uri
            }
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(e)
            )

    async def verify_totp_factor(self, factor_id: str, code: str) -> Dict[str, str]:
        """
        Verify a TOTP factor during enrollment.
        """
        try:
            session = self.client.auth.get_session()
            if not session:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="No active session"
                )

            # Create a challenge first
            challenge = self.client.auth.mfa.challenge({
                "factor_id": factor_id
            })

            if not challenge or not challenge.id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Failed to create challenge"
                )

            # Verify the challenge with the provided code
            verify_result = self.client.auth.mfa.verify({
                "factor_id": factor_id,
                "challenge_id": challenge.id,
                "code": code
            })

            if not verify_result:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Invalid verification code"
                )

            return {"message": "TOTP factor verified successfully"}
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(e)
            )

    async def challenge_totp_factor(self, factor_id: str, code: str) -> Dict[str, Any]:
        """
        Challenge a TOTP factor during login.
        """
        try:
            session = self.client.auth.get_session()
            if not session:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="No active session"
                )

            # Create a challenge
            challenge = self.client.auth.mfa.challenge({
                "factor_id": factor_id
            })

            if not challenge or not challenge.id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Failed to create challenge"
                )

            # Verify the challenge
            verify_result = self.client.auth.mfa.verify_challenge({
                "factor_id": factor_id,
                "challenge_id": challenge.id,
                "code": code
            })

            if not verify_result or not verify_result.session:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Invalid verification code"
                )

            return {
                "session": verify_result.session,
                "message": "MFA challenge completed successfully"
            }
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(e)
            )

    async def disable_totp_factor(self, factor_id: Optional[str], code: str) -> Dict[str, str]:
        """
        Disable TOTP factor for MFA.
        Requires current TOTP code for security verification.
        """
        try:
            # Get the current session
            session = self.client.auth.get_session()
            if not session:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="No active session"
                )

            # Get user's factors if factor_id is not provided
            if not factor_id:
                factors_response = self.client.auth.mfa.list_factors()
                if not factors_response or not factors_response.all:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail="No TOTP factor found"
                    )

                # Find the verified TOTP factor
                totp_factor = next(
                    (f for f in factors_response.all if f.factor_type == "totp" and f.status == "verified"),
                    None
                )

                if not totp_factor:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail="No verified TOTP factor found"
                    )
                
                factor_id = totp_factor.id

            # Create a challenge first
            challenge = self.client.auth.mfa.challenge({
                "factor_id": factor_id
            })

            if not challenge or not challenge.id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Failed to create challenge"
                )

            # Verify the challenge with the provided code
            verify_result = self.client.auth.mfa.verify({
                "factor_id": factor_id,
                "challenge_id": challenge.id,
                "code": code
            })

            if not verify_result:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid verification code"
                )

            # Unenroll the TOTP factor
            self.client.auth.mfa.unenroll({
                "factor_id": factor_id
            })

            return {"message": "TOTP factor disabled successfully"}
        except Exception as e:
            if "No TOTP factor found" in str(e):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="2FA is not enabled for this account"
                )
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(e)
            )

    async def delete_account(self, password: str) -> Dict[str, str]:
        """
        Delete user account and all associated data.
        Uses service role key for secure deletion.
        """
        try:
            # Get current session
            session = self.client.auth.get_session()
            if not session:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="No active session"
                )

            # Verify password before deletion
            try:
                self.client.auth.sign_in_with_password({
                    "email": session.user.email,
                    "password": password
                })
            except Exception:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid password"
                )

            user_id = session.user.id

            # Create a new Supabase client with service role key
            admin_client = settings.supabase_admin

            try:
                # 1. First delete user data from public tables using service role
                # This bypasses RLS policies
                admin_client.from_("users").delete().eq("id", user_id).execute()
                
                # Add more delete operations for other tables if needed
                # Example:
                # admin_client.from_("user_preferences").delete().eq("user_id", user_id).execute()

                # 2. Delete any storage objects
                buckets = admin_client.storage.list_buckets()
                for bucket in buckets:
                    try:
                        objects = admin_client.storage.from_(bucket.name).list()
                        for obj in objects:
                            if obj.owner == user_id:
                                admin_client.storage.from_(bucket.name).remove([obj.name])
                    except Exception as e:
                        print(f"Error cleaning up storage in bucket {bucket.name}: {str(e)}")

                # 3. Finally delete the user from auth.users
                admin_client.auth.admin.delete_user(user_id)

                return {"message": "Account deleted successfully"}
            except Exception as e:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Failed to delete account: {str(e)}"
                )

        except Exception as e:
            if "Invalid password" not in str(e):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=str(e)
                )
            raise

    async def get_mfa_status(self) -> Dict[str, Any]:
        """
        Get MFA status for the current user.
        """
        try:
            session = self.client.auth.get_session()
            if not session:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="No active session"
                )

            # Get user's factors
            factors = session.user.factors or []
            
            return {
                "is_enabled": len(factors) > 0,
                "factors": [f.factor_type for f in factors],
                "preferred_factor": factors[0].factor_type if factors else None
            }
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(e)
            )

# Create global auth service instance
auth_service = AuthService() 