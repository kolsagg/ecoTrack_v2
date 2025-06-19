// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceRegistrationRequest _$DeviceRegistrationRequestFromJson(
  Map<String, dynamic> json,
) => DeviceRegistrationRequest(
  deviceId: json['device_id'] as String,
  fcmToken: json['fcm_token'] as String,
  deviceType: json['device_type'] as String,
  deviceName: json['device_name'] as String?,
  appVersion: json['app_version'] as String?,
  osVersion: json['os_version'] as String?,
);

Map<String, dynamic> _$DeviceRegistrationRequestToJson(
  DeviceRegistrationRequest instance,
) => <String, dynamic>{
  'device_id': instance.deviceId,
  'fcm_token': instance.fcmToken,
  'device_type': instance.deviceType,
  'device_name': instance.deviceName,
  'app_version': instance.appVersion,
  'os_version': instance.osVersion,
};

DeviceRegistrationResponse _$DeviceRegistrationResponseFromJson(
  Map<String, dynamic> json,
) => DeviceRegistrationResponse(
  deviceId: json['device_id'] as String,
  registeredAt: DateTime.parse(json['registered_at'] as String),
  status: json['status'] as String,
);

Map<String, dynamic> _$DeviceRegistrationResponseToJson(
  DeviceRegistrationResponse instance,
) => <String, dynamic>{
  'device_id': instance.deviceId,
  'registered_at': instance.registeredAt.toIso8601String(),
  'status': instance.status,
};

DeviceResponse _$DeviceResponseFromJson(Map<String, dynamic> json) =>
    DeviceResponse(
      id: json['id'] as String,
      deviceId: json['device_id'] as String,
      deviceType: json['device_type'] as String,
      deviceName: json['device_name'] as String?,
      isActive: json['is_active'] as bool,
      lastUsedAt: DateTime.parse(json['last_used_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$DeviceResponseToJson(DeviceResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'device_id': instance.deviceId,
      'device_type': instance.deviceType,
      'device_name': instance.deviceName,
      'is_active': instance.isActive,
      'last_used_at': instance.lastUsedAt.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

DeviceListResponse _$DeviceListResponseFromJson(Map<String, dynamic> json) =>
    DeviceListResponse(
      devices: (json['devices'] as List<dynamic>)
          .map((e) => DeviceResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DeviceListResponseToJson(DeviceListResponse instance) =>
    <String, dynamic>{'devices': instance.devices};

DeviceDeactivationResponse _$DeviceDeactivationResponseFromJson(
  Map<String, dynamic> json,
) => DeviceDeactivationResponse(
  deviceId: json['device_id'] as String,
  status: json['status'] as String,
  deactivatedAt: DateTime.parse(json['deactivated_at'] as String),
);

Map<String, dynamic> _$DeviceDeactivationResponseToJson(
  DeviceDeactivationResponse instance,
) => <String, dynamic>{
  'device_id': instance.deviceId,
  'status': instance.status,
  'deactivated_at': instance.deactivatedAt.toIso8601String(),
};
