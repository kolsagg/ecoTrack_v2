import 'package:flutter/foundation.dart';

enum Environment {
  dev,
  prod,
}

class AppConfig {
  final Environment environment;
  final String apiBaseUrl;
  final bool enableLogging;
  final int connectTimeout;
  final int receiveTimeout;

  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    this.enableLogging = false,
    this.connectTimeout = 30000,
    this.receiveTimeout = 30000,
  });

  static late AppConfig _instance;

  static AppConfig get instance => _instance;

  static void initialize({required Environment environment}) {
    switch (environment) {
      case Environment.dev:
        _instance = AppConfig(
          environment: environment,
          apiBaseUrl: 'https://api.dev.ecotrack.app/api/v1',
          enableLogging: true,
        );
        break;
      case Environment.prod:
        _instance = AppConfig(
          environment: environment,
          apiBaseUrl: 'https://api.ecotrack.app/api/v1',
          enableLogging: false,
        );
        break;
    }
    debugPrint('AppConfig initialized with environment: ${environment.name}');
    debugPrint('API Base URL: ${_instance.apiBaseUrl}');
  }

  bool get isDev => environment == Environment.dev;
  bool get isProd => environment == Environment.prod;
} 