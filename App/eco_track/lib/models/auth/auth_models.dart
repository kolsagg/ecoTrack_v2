import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'user_model.dart';

part 'auth_models.g.dart';

// Login Request
@JsonSerializable()
class LoginRequest extends Equatable {
  final String email;
  final String password;
  @JsonKey(name: 'remember_me')
  final bool? rememberMe;
  @JsonKey(name: 'device_info')
  final Map<String, dynamic>? deviceInfo;

  const LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe,
    this.deviceInfo,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);

  @override
  List<Object?> get props => [email, password, rememberMe, deviceInfo];
}

// Register Request
@JsonSerializable()
class RegisterRequest extends Equatable {
  final String email;
  final String password;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);

  @override
  List<Object> get props => [email, password, firstName, lastName];
}

// Register Response (different from AuthResponse)
@JsonSerializable()
class RegisterResponse extends Equatable {
  final String? message;
  final User? user;

  const RegisterResponse({this.message, this.user});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResponseToJson(this);

  @override
  List<Object?> get props => [message, user];
}

// Auth Response (for login/register)
@JsonSerializable()
class AuthResponse extends Equatable {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;
  @JsonKey(name: 'token_type')
  final String tokenType;
  @JsonKey(name: 'expires_in')
  final int? expiresIn;
  @JsonKey(name: 'remember_token')
  final String? rememberToken;
  @JsonKey(name: 'remember_expires_in')
  final int? rememberExpiresIn;
  final User user;

  const AuthResponse({
    required this.accessToken,
    this.refreshToken,
    required this.tokenType,
    this.expiresIn,
    this.rememberToken,
    this.rememberExpiresIn,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  @override
  List<Object?> get props => [
    accessToken,
    refreshToken,
    tokenType,
    expiresIn,
    rememberToken,
    rememberExpiresIn,
    user,
  ];
}

// Password Reset Request
@JsonSerializable()
class PasswordResetRequest extends Equatable {
  final String email;

  const PasswordResetRequest({required this.email});

  factory PasswordResetRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PasswordResetRequestToJson(this);

  @override
  List<Object> get props => [email];
}

// Password Reset Confirm Request
@JsonSerializable()
class PasswordResetConfirmRequest extends Equatable {
  final String token;
  @JsonKey(name: 'new_password')
  final String newPassword;

  const PasswordResetConfirmRequest({
    required this.token,
    required this.newPassword,
  });

  factory PasswordResetConfirmRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetConfirmRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PasswordResetConfirmRequestToJson(this);

  @override
  List<Object> get props => [token, newPassword];
}

// MFA Status Response
@JsonSerializable()
class MfaStatusResponse extends Equatable {
  @JsonKey(name: 'is_enabled')
  final bool isEnabled;
  @JsonKey(name: 'backup_codes_count')
  final int? backupCodesCount;

  const MfaStatusResponse({required this.isEnabled, this.backupCodesCount});

  factory MfaStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$MfaStatusResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MfaStatusResponseToJson(this);

  @override
  List<Object?> get props => [isEnabled, backupCodesCount];
}

// TOTP Create Response
@JsonSerializable()
class TotpCreateResponse extends Equatable {
  @JsonKey(name: 'secret_key')
  final String secretKey;
  @JsonKey(name: 'qr_code_url')
  final String qrCodeUrl;
  @JsonKey(name: 'backup_codes')
  final List<String> backupCodes;

  const TotpCreateResponse({
    required this.secretKey,
    required this.qrCodeUrl,
    required this.backupCodes,
  });

  factory TotpCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$TotpCreateResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TotpCreateResponseToJson(this);

  @override
  List<Object> get props => [secretKey, qrCodeUrl, backupCodes];
}

// TOTP Verify Request
@JsonSerializable()
class TotpVerifyRequest extends Equatable {
  final String code;

  const TotpVerifyRequest({required this.code});

  factory TotpVerifyRequest.fromJson(Map<String, dynamic> json) =>
      _$TotpVerifyRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TotpVerifyRequestToJson(this);

  @override
  List<Object> get props => [code];
}

// Account Delete Request
@JsonSerializable()
class AccountDeleteRequest extends Equatable {
  final String password;

  const AccountDeleteRequest({required this.password});

  factory AccountDeleteRequest.fromJson(Map<String, dynamic> json) =>
      _$AccountDeleteRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AccountDeleteRequestToJson(this);

  @override
  List<Object> get props => [password];
}

// Password Change Request
@JsonSerializable()
class PasswordChangeRequest extends Equatable {
  @JsonKey(name: 'current_password')
  final String currentPassword;
  @JsonKey(name: 'new_password')
  final String newPassword;

  const PasswordChangeRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  factory PasswordChangeRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordChangeRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PasswordChangeRequestToJson(this);

  @override
  List<Object> get props => [currentPassword, newPassword];
}

// TOTP Disable Request
@JsonSerializable()
class TotpDisableRequest extends Equatable {
  final String password;

  const TotpDisableRequest({required this.password});

  factory TotpDisableRequest.fromJson(Map<String, dynamic> json) =>
      _$TotpDisableRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TotpDisableRequestToJson(this);

  @override
  List<Object> get props => [password];
}

// Generic Success Response
@JsonSerializable()
class SuccessResponse extends Equatable {
  final String message;
  final bool success;

  const SuccessResponse({required this.message, this.success = true});

  factory SuccessResponse.fromJson(Map<String, dynamic> json) =>
      _$SuccessResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SuccessResponseToJson(this);

  @override
  List<Object> get props => [message, success];
}

// Profile Update Request
@JsonSerializable()
class ProfileUpdateRequest extends Equatable {
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  final String? email;

  const ProfileUpdateRequest({this.firstName, this.lastName, this.email});

  factory ProfileUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ProfileUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileUpdateRequestToJson(this);

  @override
  List<Object?> get props => [firstName, lastName, email];
}

// Remember Me Login Request
@JsonSerializable()
class RememberMeLoginRequest extends Equatable {
  @JsonKey(name: 'remember_token')
  final String rememberToken;
  @JsonKey(name: 'device_id')
  final String deviceId;
  @JsonKey(name: 'device_info')
  final Map<String, dynamic> deviceInfo;

  const RememberMeLoginRequest({
    required this.rememberToken,
    required this.deviceId,
    required this.deviceInfo,
  });

  factory RememberMeLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$RememberMeLoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RememberMeLoginRequestToJson(this);

  @override
  List<Object> get props => [rememberToken, deviceId, deviceInfo];
}
