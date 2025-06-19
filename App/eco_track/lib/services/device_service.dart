import 'package:dio/dio.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../config/api_config.dart';
import '../core/errors/exceptions.dart';
import '../models/device/device_models.dart';
import 'auth_service.dart';
import 'storage_service.dart';

class DeviceService {
  final AuthService _authService;
  final StorageService _storageService;
  final Dio _dio;

  DeviceService({
    required AuthService authService,
    required StorageService storageService,
    required Dio dio,
  }) : _authService = authService,
       _storageService = storageService,
       _dio = dio;

  // Get current device info
  Future<DeviceInfo> getCurrentDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    String deviceId;
    String deviceType;
    String? deviceName;
    String? osVersion;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      deviceId = androidInfo.id;
      deviceType = 'android';
      deviceName = '${androidInfo.brand} ${androidInfo.model}';
      osVersion = 'Android ${androidInfo.version.release}';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? 'unknown_ios_device';
      deviceType = 'ios';
      deviceName = '${iosInfo.name} (${iosInfo.model})';
      osVersion = 'iOS ${iosInfo.systemVersion}';
    } else {
      deviceId = 'unknown_device';
      deviceType = 'unknown';
      deviceName = 'Unknown Device';
      osVersion = 'Unknown OS';
    }

    return DeviceInfo(
      deviceId: deviceId,
      deviceType: deviceType,
      deviceName: deviceName,
      appVersion: packageInfo.version,
      osVersion: osVersion,
    );
  }

  // Register device
  Future<DeviceRegistrationResponse> registerDevice({String? fcmToken}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final deviceInfo = await getCurrentDeviceInfo();

      final request = DeviceRegistrationRequest(
        deviceId: deviceInfo.deviceId,
        fcmToken: fcmToken ?? 'no_fcm_token', // Placeholder for now
        deviceType: deviceInfo.deviceType,
        deviceName: deviceInfo.deviceName,
        appVersion: deviceInfo.appVersion,
        osVersion: deviceInfo.osVersion,
      );

      final response = await _dio.post(
        ApiConfig.deviceRegisterEndpoint,
        data: request.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final registrationResponse = DeviceRegistrationResponse.fromJson(
        response.data,
      );

      // Save device registration info locally
      await _saveDeviceRegistrationInfo(
        deviceInfo.copyWith(fcmToken: fcmToken),
      );

      return registrationResponse;
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to register device',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error registering device: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error registering device: $e');
    }
  }

  // Get user devices
  Future<DeviceListResponse> getUserDevices() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final response = await _dio.get(
        ApiConfig.devicesEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // Handle both array response and object with devices array
      List<dynamic> devicesData;
      if (response.data is List) {
        devicesData = response.data;
      } else if (response.data is Map && response.data['devices'] != null) {
        devicesData = response.data['devices'];
      } else {
        devicesData = [];
      }

      final devices = devicesData
          .map((device) => DeviceResponse.fromJson(device))
          .toList();

      return DeviceListResponse(devices: devices);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to fetch devices',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error fetching devices: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error fetching devices: $e');
    }
  }

  // Deactivate device
  Future<DeviceDeactivationResponse> deactivateDevice(String deviceId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final response = await _dio.put(
        '${ApiConfig.devicesEndpoint}/$deviceId/deactivate',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return DeviceDeactivationResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to deactivate device',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error deactivating device: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error deactivating device: $e');
    }
  }

  // Delete device
  Future<void> deleteDevice(String deviceId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      await _dio.delete(
        '${ApiConfig.devicesEndpoint}/$deviceId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to delete device',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error deleting device: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error deleting device: $e');
    }
  }

  // Check if current device is registered
  Future<bool> isCurrentDeviceRegistered() async {
    try {
      final devices = await getUserDevices();
      final currentDevice = await getCurrentDeviceInfo();

      return devices.devices.any(
        (device) =>
            device.deviceId == currentDevice.deviceId && device.isActive,
      );
    } catch (e) {
      return false;
    }
  }

  // Auto-register device if not registered
  Future<void> autoRegisterDeviceIfNeeded() async {
    try {
      final isRegistered = await isCurrentDeviceRegistered();
      if (!isRegistered) {
        await registerDevice();
      }
    } catch (e) {
      // Silently fail for auto-registration
      print('Auto-registration failed: $e');
    }
  }

  // Save device registration info locally
  Future<void> _saveDeviceRegistrationInfo(DeviceInfo deviceInfo) async {
    const key = 'device_registration_info';
    final data = {
      'deviceId': deviceInfo.deviceId,
      'deviceType': deviceInfo.deviceType,
      'deviceName': deviceInfo.deviceName,
      'appVersion': deviceInfo.appVersion,
      'osVersion': deviceInfo.osVersion,
      'fcmToken': deviceInfo.fcmToken,
      'registeredAt': DateTime.now().toIso8601String(),
    };

    await _storageService.saveData(key, data.toString());
  }

  // Get local device registration info
  Future<DeviceInfo?> getLocalDeviceInfo() async {
    try {
      const key = 'device_registration_info';
      final data = await _storageService.getData(key);
      if (data != null) {
        // Parse stored device info
        // This is a simplified version - in production you'd use proper JSON parsing
        return await getCurrentDeviceInfo();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update FCM token
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      // Re-register device with new FCM token
      await registerDevice(fcmToken: fcmToken);
    } catch (e) {
      print('Failed to update FCM token: $e');
    }
  }
}
