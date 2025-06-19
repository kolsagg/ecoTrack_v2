import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../models/device/device_models.dart';
import '../services/device_service.dart';
import '../core/utils/dependency_injection.dart';

// Device State
class DeviceState extends Equatable {
  final List<DeviceResponse> devices;
  final DeviceInfo? currentDevice;
  final bool isLoading;
  final String? error;
  final bool isRegistered;

  const DeviceState({
    this.devices = const [],
    this.currentDevice,
    this.isLoading = false,
    this.error,
    this.isRegistered = false,
  });

  DeviceState copyWith({
    List<DeviceResponse>? devices,
    DeviceInfo? currentDevice,
    bool? isLoading,
    String? error,
    bool? isRegistered,
  }) {
    return DeviceState(
      devices: devices ?? this.devices,
      currentDevice: currentDevice ?? this.currentDevice,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }

  @override
  List<Object?> get props => [
    devices,
    currentDevice,
    isLoading,
    error,
    isRegistered,
  ];
}

// Device Notifier
class DeviceNotifier extends StateNotifier<DeviceState> {
  final DeviceService _deviceService;

  DeviceNotifier(this._deviceService) : super(const DeviceState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadCurrentDevice();
    await checkRegistrationStatus();
  }

  // Load current device info
  Future<void> loadCurrentDevice() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final deviceInfo = await _deviceService.getCurrentDeviceInfo();
      state = state.copyWith(currentDevice: deviceInfo, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Cihaz bilgileri yüklenemedi: $e',
        isLoading: false,
      );
    }
  }

  // Check if current device is registered
  Future<void> checkRegistrationStatus() async {
    try {
      final isRegistered = await _deviceService.isCurrentDeviceRegistered();
      state = state.copyWith(isRegistered: isRegistered);
    } catch (e) {
      state = state.copyWith(isRegistered: false);
    }
  }

  // Register current device
  Future<bool> registerDevice({String? fcmToken}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _deviceService.registerDevice(fcmToken: fcmToken);
      state = state.copyWith(isLoading: false, isRegistered: true);
      await loadUserDevices(); // Refresh device list
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Cihaz kaydedilemedi: $e',
        isLoading: false,
        isRegistered: false,
      );
      return false;
    }
  }

  // Load user devices
  Future<void> loadUserDevices() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final response = await _deviceService.getUserDevices();
      state = state.copyWith(devices: response.devices, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Cihazlar yüklenemedi: $e',
        isLoading: false,
      );
    }
  }

  // Deactivate device
  Future<bool> deactivateDevice(String deviceId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _deviceService.deactivateDevice(deviceId);

      // Update local state
      final updatedDevices = state.devices.map((device) {
        if (device.id == deviceId) {
          return DeviceResponse(
            id: device.id,
            deviceId: device.deviceId,
            deviceType: device.deviceType,
            deviceName: device.deviceName,
            isActive: false,
            lastUsedAt: device.lastUsedAt,
            createdAt: device.createdAt,
          );
        }
        return device;
      }).toList();

      state = state.copyWith(devices: updatedDevices, isLoading: false);

      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Cihaz deaktif edilemedi: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Delete device
  Future<bool> deleteDevice(String deviceId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _deviceService.deleteDevice(deviceId);

      // Remove from local state
      final updatedDevices = state.devices
          .where((device) => device.id != deviceId)
          .toList();
      state = state.copyWith(devices: updatedDevices, isLoading: false);

      return true;
    } catch (e) {
      state = state.copyWith(error: 'Cihaz silinemedi: $e', isLoading: false);
      return false;
    }
  }

  // Auto-register device if needed
  Future<void> autoRegisterIfNeeded() async {
    if (!state.isRegistered) {
      await _deviceService.autoRegisterDeviceIfNeeded();
      await checkRegistrationStatus();
    }
  }

  // Update FCM token
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await _deviceService.updateFcmToken(fcmToken);
      // Update current device info
      if (state.currentDevice != null) {
        state = state.copyWith(
          currentDevice: state.currentDevice!.copyWith(fcmToken: fcmToken),
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'FCM token güncellenemedi: $e');
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Reset state
  void reset() {
    state = const DeviceState();
  }
}

// Providers
final deviceServiceProvider = Provider<DeviceService>((ref) {
  return getIt<DeviceService>();
});

final deviceProvider = StateNotifierProvider<DeviceNotifier, DeviceState>((
  ref,
) {
  final deviceService = ref.read(deviceServiceProvider);
  return DeviceNotifier(deviceService);
});
