import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'device_models.g.dart';

// Device Registration Request
@JsonSerializable()
class DeviceRegistrationRequest extends Equatable {
  @JsonKey(name: 'device_id')
  final String deviceId;
  @JsonKey(name: 'fcm_token')
  final String fcmToken;
  @JsonKey(name: 'device_type')
  final String deviceType;
  @JsonKey(name: 'device_name')
  final String? deviceName;
  @JsonKey(name: 'app_version')
  final String? appVersion;
  @JsonKey(name: 'os_version')
  final String? osVersion;

  const DeviceRegistrationRequest({
    required this.deviceId,
    required this.fcmToken,
    required this.deviceType,
    this.deviceName,
    this.appVersion,
    this.osVersion,
  });

  factory DeviceRegistrationRequest.fromJson(Map<String, dynamic> json) =>
      _$DeviceRegistrationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceRegistrationRequestToJson(this);

  @override
  List<Object?> get props => [
    deviceId,
    fcmToken,
    deviceType,
    deviceName,
    appVersion,
    osVersion,
  ];
}

// Device Registration Response
@JsonSerializable()
class DeviceRegistrationResponse extends Equatable {
  @JsonKey(name: 'device_id')
  final String deviceId;
  @JsonKey(name: 'registered_at')
  final DateTime registeredAt;
  final String status;

  const DeviceRegistrationResponse({
    required this.deviceId,
    required this.registeredAt,
    required this.status,
  });

  factory DeviceRegistrationResponse.fromJson(Map<String, dynamic> json) =>
      _$DeviceRegistrationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceRegistrationResponseToJson(this);

  @override
  List<Object?> get props => [deviceId, registeredAt, status];
}

// Device Response
@JsonSerializable()
class DeviceResponse extends Equatable {
  final String id;
  @JsonKey(name: 'device_id')
  final String deviceId;
  @JsonKey(name: 'device_type')
  final String deviceType;
  @JsonKey(name: 'device_name')
  final String? deviceName;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'last_used_at')
  final DateTime lastUsedAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const DeviceResponse({
    required this.id,
    required this.deviceId,
    required this.deviceType,
    this.deviceName,
    required this.isActive,
    required this.lastUsedAt,
    required this.createdAt,
  });

  factory DeviceResponse.fromJson(Map<String, dynamic> json) =>
      _$DeviceResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceResponseToJson(this);

  @override
  List<Object?> get props => [
    id,
    deviceId,
    deviceType,
    deviceName,
    isActive,
    lastUsedAt,
    createdAt,
  ];
}

// Device List Response
@JsonSerializable()
class DeviceListResponse extends Equatable {
  final List<DeviceResponse> devices;

  const DeviceListResponse({required this.devices});

  factory DeviceListResponse.fromJson(Map<String, dynamic> json) =>
      _$DeviceListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceListResponseToJson(this);

  @override
  List<Object?> get props => [devices];
}

// Device Deactivation Response
@JsonSerializable()
class DeviceDeactivationResponse extends Equatable {
  @JsonKey(name: 'device_id')
  final String deviceId;
  final String status;
  @JsonKey(name: 'deactivated_at')
  final DateTime deactivatedAt;

  const DeviceDeactivationResponse({
    required this.deviceId,
    required this.status,
    required this.deactivatedAt,
  });

  factory DeviceDeactivationResponse.fromJson(Map<String, dynamic> json) =>
      _$DeviceDeactivationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceDeactivationResponseToJson(this);

  @override
  List<Object?> get props => [deviceId, status, deactivatedAt];
}

// Device Info (for current device)
class DeviceInfo extends Equatable {
  final String deviceId;
  final String deviceType;
  final String? deviceName;
  final String? appVersion;
  final String? osVersion;
  final String? fcmToken;

  const DeviceInfo({
    required this.deviceId,
    required this.deviceType,
    this.deviceName,
    this.appVersion,
    this.osVersion,
    this.fcmToken,
  });

  @override
  List<Object?> get props => [
    deviceId,
    deviceType,
    deviceName,
    appVersion,
    osVersion,
    fcmToken,
  ];

  DeviceInfo copyWith({
    String? deviceId,
    String? deviceType,
    String? deviceName,
    String? appVersion,
    String? osVersion,
    String? fcmToken,
  }) {
    return DeviceInfo(
      deviceId: deviceId ?? this.deviceId,
      deviceType: deviceType ?? this.deviceType,
      deviceName: deviceName ?? this.deviceName,
      appVersion: appVersion ?? this.appVersion,
      osVersion: osVersion ?? this.osVersion,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
