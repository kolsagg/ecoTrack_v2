from fastapi import APIRouter, Depends, HTTPException, status
from app.core.auth import auth_service
from app.schemas.auth import (
    UserSignUp,
    UserLogin,
    PasswordReset,
    PasswordResetConfirm,
    AuthResponse,
    Token,
    TOTPFactorCreate,
    TOTPFactorVerify,
    TOTPFactorChallenge,
    TOTPFactorDisable,
    DeleteAccount,
    MFAStatus,
    BackupCodes
)

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/signup", response_model=AuthResponse)
async def signup(user_data: UserSignUp):
    """
    Register a new user.
    """
    result = await auth_service.sign_up(user_data)
    return AuthResponse(message=result["message"], data=result.get("user"))

@router.post("/login", response_model=Token)
async def login(credentials: UserLogin):
    """
    Login with email and password.
    """
    return await auth_service.login(credentials)

@router.post("/password-reset", response_model=AuthResponse)
async def request_password_reset(email_data: PasswordReset):
    """
    Request password reset email.
    """
    result = await auth_service.reset_password(email_data.email)
    return AuthResponse(message=result["message"])

@router.post("/password-reset/confirm", response_model=AuthResponse)
async def confirm_password_reset(reset_data: PasswordResetConfirm):
    """
    Reset password with token.
    """
    result = await auth_service.confirm_password_reset(
        reset_data.token, 
        reset_data.new_password
    )
    return AuthResponse(message=result["message"])

@router.post("/mfa/totp/new", response_model=AuthResponse)
async def create_totp_factor():
    """
    Create a new TOTP factor for the authenticated user.
    Returns a QR code and secret that should be saved in an authenticator app.
    """
    result = await auth_service.create_totp_factor()
    return AuthResponse(
        message="TOTP factor created successfully. Please scan the QR code.",
        data=result
    )

@router.post("/mfa/totp/verify", response_model=AuthResponse)
async def verify_totp_factor(verify_data: TOTPFactorVerify):
    """
    Verify a TOTP factor using a code from the authenticator app.
    This completes the enrollment of the TOTP factor.
    """
    # Eğer factor_id verilmemişse, ilk TOTP faktörünü bul
    if not verify_data.factor_id:
        factors = await auth_service.list_mfa_factors()
        totp_factors = factors.get("totp", [])
        if not totp_factors:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No TOTP factor found"
            )
        verify_data.factor_id = totp_factors[0]["id"]

    result = await auth_service.verify_totp_factor(
        factor_id=verify_data.factor_id,
        code=verify_data.code
    )
    return AuthResponse(message="TOTP factor verified successfully")

@router.post("/mfa/totp/challenge", response_model=AuthResponse)
async def challenge_totp_factor(challenge_data: TOTPFactorChallenge):
    """
    Challenge a TOTP factor during login.
    This verifies the TOTP code during the login process.
    """
    # Eğer factor_id verilmemişse, ilk TOTP faktörünü bul
    if not challenge_data.factor_id:
        factors = await auth_service.list_mfa_factors()
        totp_factors = factors.get("totp", [])
        if not totp_factors:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No TOTP factor found"
            )
        challenge_data.factor_id = totp_factors[0]["id"]

    result = await auth_service.challenge_totp_factor(
        factor_id=challenge_data.factor_id,
        code=challenge_data.code
    )
    return AuthResponse(
        message="TOTP challenge successful",
        data={"session": result}
    )

@router.post("/mfa/totp/disable", response_model=AuthResponse)
async def disable_totp_factor(disable_data: TOTPFactorDisable):
    """
    Disable TOTP factor for the authenticated user.
    Requires the current TOTP code for security verification.
    """
    result = await auth_service.disable_totp_factor(
        factor_id=disable_data.factor_id,
        code=disable_data.code
    )
    return AuthResponse(message=result["message"])

@router.delete("/account", response_model=AuthResponse)
async def delete_account(delete_data: DeleteAccount):
    """
    Delete user account and all associated data.
    Requires password confirmation for security.
    """
    result = await auth_service.delete_account(delete_data.password)
    return AuthResponse(message="Account deleted successfully")

@router.get("/mfa/status", response_model=MFAStatus)
async def get_mfa_status():
    """
    Get the current MFA status for the authenticated user.
    Returns whether 2FA is enabled and the type of factors enabled.
    """
    result = await auth_service.get_mfa_status()
    return result

@router.post("/mfa/backup-codes/new", response_model=BackupCodes)
async def generate_backup_codes():
    """
    Generate new backup codes for 2FA.
    Previous backup codes will be invalidated.
    """
    result = await auth_service.generate_backup_codes()
    return result

@router.get("/mfa/backup-codes", response_model=BackupCodes)
async def get_backup_codes():
    """
    Get the current backup codes for the authenticated user.
    Only available if 2FA is enabled.
    """
    result = await auth_service.get_backup_codes()
    return result 