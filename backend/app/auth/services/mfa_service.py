from typing import Dict, Any, Optional
from fastapi import HTTPException, status
from app.core.config import settings

class MFAService:
    def __init__(self):
        self.client = settings.supabase

    async def get_authenticator_assurance_level(self) -> Dict[str, str]:
        """
        Get the current and next authenticator assurance level (AAL) for the user.
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

            challenge = self.client.auth.mfa.challenge({
                "factor_id": factor_id
            })

            if not challenge or not challenge.id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Failed to create challenge"
                )

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

            challenge = self.client.auth.mfa.challenge({
                "factor_id": factor_id
            })

            if not challenge or not challenge.id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Failed to create challenge"
                )

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
        """
        try:
            session = self.client.auth.get_session()
            if not session:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="No active session"
                )

            if not factor_id:
                factors_response = self.client.auth.mfa.list_factors()
                if not factors_response or not factors_response.all:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail="No TOTP factor found"
                    )

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

            challenge = self.client.auth.mfa.challenge({
                "factor_id": factor_id
            })

            if not challenge or not challenge.id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Failed to create challenge"
                )

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

# Create global MFA service instance
mfa_service = MFAService() 