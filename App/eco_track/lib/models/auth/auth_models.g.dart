// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  email: json['email'] as String,
  password: json['password'] as String,
  rememberMe: json['remember_me'] as bool?,
  deviceInfo: json['device_info'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'remember_me': instance.rememberMe,
      'device_info': instance.deviceInfo,
    };

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
    };

RegisterResponse _$RegisterResponseFromJson(Map<String, dynamic> json) =>
    RegisterResponse(
      message: json['message'] as String?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RegisterResponseToJson(RegisterResponse instance) =>
    <String, dynamic>{'message': instance.message, 'user': instance.user};

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String?,
  tokenType: json['token_type'] as String,
  expiresIn: (json['expires_in'] as num?)?.toInt(),
  rememberToken: json['remember_token'] as String?,
  rememberExpiresIn: (json['remember_expires_in'] as num?)?.toInt(),
  user: User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'token_type': instance.tokenType,
      'expires_in': instance.expiresIn,
      'remember_token': instance.rememberToken,
      'remember_expires_in': instance.rememberExpiresIn,
      'user': instance.user,
    };

PasswordResetRequest _$PasswordResetRequestFromJson(
  Map<String, dynamic> json,
) => PasswordResetRequest(email: json['email'] as String);

Map<String, dynamic> _$PasswordResetRequestToJson(
  PasswordResetRequest instance,
) => <String, dynamic>{'email': instance.email};

PasswordResetConfirmRequest _$PasswordResetConfirmRequestFromJson(
  Map<String, dynamic> json,
) => PasswordResetConfirmRequest(
  token: json['token'] as String,
  newPassword: json['new_password'] as String,
);

Map<String, dynamic> _$PasswordResetConfirmRequestToJson(
  PasswordResetConfirmRequest instance,
) => <String, dynamic>{
  'token': instance.token,
  'new_password': instance.newPassword,
};

MfaStatusResponse _$MfaStatusResponseFromJson(Map<String, dynamic> json) =>
    MfaStatusResponse(
      isEnabled: json['is_enabled'] as bool,
      backupCodesCount: (json['backup_codes_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MfaStatusResponseToJson(MfaStatusResponse instance) =>
    <String, dynamic>{
      'is_enabled': instance.isEnabled,
      'backup_codes_count': instance.backupCodesCount,
    };

TotpCreateResponse _$TotpCreateResponseFromJson(Map<String, dynamic> json) =>
    TotpCreateResponse(
      secretKey: json['secret_key'] as String,
      qrCodeUrl: json['qr_code_url'] as String,
      backupCodes: (json['backup_codes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$TotpCreateResponseToJson(TotpCreateResponse instance) =>
    <String, dynamic>{
      'secret_key': instance.secretKey,
      'qr_code_url': instance.qrCodeUrl,
      'backup_codes': instance.backupCodes,
    };

TotpVerifyRequest _$TotpVerifyRequestFromJson(Map<String, dynamic> json) =>
    TotpVerifyRequest(code: json['code'] as String);

Map<String, dynamic> _$TotpVerifyRequestToJson(TotpVerifyRequest instance) =>
    <String, dynamic>{'code': instance.code};

AccountDeleteRequest _$AccountDeleteRequestFromJson(
  Map<String, dynamic> json,
) => AccountDeleteRequest(password: json['password'] as String);

Map<String, dynamic> _$AccountDeleteRequestToJson(
  AccountDeleteRequest instance,
) => <String, dynamic>{'password': instance.password};

PasswordChangeRequest _$PasswordChangeRequestFromJson(
  Map<String, dynamic> json,
) => PasswordChangeRequest(
  currentPassword: json['current_password'] as String,
  newPassword: json['new_password'] as String,
);

Map<String, dynamic> _$PasswordChangeRequestToJson(
  PasswordChangeRequest instance,
) => <String, dynamic>{
  'current_password': instance.currentPassword,
  'new_password': instance.newPassword,
};

TotpDisableRequest _$TotpDisableRequestFromJson(Map<String, dynamic> json) =>
    TotpDisableRequest(password: json['password'] as String);

Map<String, dynamic> _$TotpDisableRequestToJson(TotpDisableRequest instance) =>
    <String, dynamic>{'password': instance.password};

SuccessResponse _$SuccessResponseFromJson(Map<String, dynamic> json) =>
    SuccessResponse(
      message: json['message'] as String,
      success: json['success'] as bool? ?? true,
    );

Map<String, dynamic> _$SuccessResponseToJson(SuccessResponse instance) =>
    <String, dynamic>{'message': instance.message, 'success': instance.success};

ProfileUpdateRequest _$ProfileUpdateRequestFromJson(
  Map<String, dynamic> json,
) => ProfileUpdateRequest(
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$ProfileUpdateRequestToJson(
  ProfileUpdateRequest instance,
) => <String, dynamic>{
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'email': instance.email,
};

RememberMeLoginRequest _$RememberMeLoginRequestFromJson(
  Map<String, dynamic> json,
) => RememberMeLoginRequest(
  rememberToken: json['remember_token'] as String,
  deviceId: json['device_id'] as String,
  deviceInfo: json['device_info'] as Map<String, dynamic>,
);

Map<String, dynamic> _$RememberMeLoginRequestToJson(
  RememberMeLoginRequest instance,
) => <String, dynamic>{
  'remember_token': instance.rememberToken,
  'device_id': instance.deviceId,
  'device_info': instance.deviceInfo,
};
