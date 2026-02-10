import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _definedBaseUrl = String.fromEnvironment(
    'SMARTLINK_API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_definedBaseUrl.trim().isNotEmpty) return _definedBaseUrl.trim();
    if (kIsWeb) return 'http://localhost:8000/api/v1';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'http://10.0.2.2:8000/api/v1',
      _ => 'http://localhost:8000/api/v1',
    };
  }
}
