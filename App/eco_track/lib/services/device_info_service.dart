import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceInfoService {
  static const String _deviceIdKey = 'device_id';
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Uuid _uuid = const Uuid();

  // Device ID'yi al veya oluştur
  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);

    if (deviceId == null) {
      deviceId = _uuid.v4();
      await prefs.setString(_deviceIdKey, deviceId);
    }

    return deviceId;
  }

  // Device type'ı belirle
  String getDeviceType() {
    if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isMacOS) {
      return 'macos';
    } else if (Platform.isWindows) {
      return 'windows';
    } else if (Platform.isLinux) {
      return 'linux';
    } else {
      return 'web';
    }
  }

  // Device name'i al
  Future<String> getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return '${iosInfo.name} (${iosInfo.model})';
      } else if (Platform.isMacOS) {
        final macInfo = await _deviceInfo.macOsInfo;
        return '${macInfo.computerName} (macOS)';
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return '${windowsInfo.computerName} (Windows)';
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        return '${linuxInfo.name} (Linux)';
      }
    } catch (e) {
      // Hata durumunda varsayılan isim döndür
      return 'Unknown Device';
    }

    return 'Web Browser';
  }

  // User agent bilgisi al
  Future<String> getUserAgent() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return 'EcoTrack/${androidInfo.version.release} (Android ${androidInfo.version.sdkInt}; ${androidInfo.model})';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return 'EcoTrack/${iosInfo.systemVersion} (iOS; ${iosInfo.model})';
      } else if (Platform.isMacOS) {
        final macInfo = await _deviceInfo.macOsInfo;
        return 'EcoTrack/1.0.0 (macOS ${macInfo.osRelease})';
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return 'EcoTrack/1.0.0 (Windows ${windowsInfo.displayVersion})';
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        return 'EcoTrack/1.0.0 (Linux ${linuxInfo.version})';
      }
    } catch (e) {
      return 'EcoTrack/1.0.0 (Unknown)';
    }

    return 'EcoTrack/1.0.0 (Web)';
  }

  // Tüm device bilgilerini topla
  Future<Map<String, dynamic>> getDeviceInfo() async {
    return {
      'device_id': await getDeviceId(),
      'device_type': getDeviceType(),
      'device_name': await getDeviceName(),
      'user_agent': await getUserAgent(),
    };
  }

  // Device ID'yi sıfırla (logout durumunda)
  Future<void> resetDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
  }
}
