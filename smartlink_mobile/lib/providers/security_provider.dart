import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecuritySettings {
  final bool biometricEnabled;
  final bool twoFactorEnabled;

  const SecuritySettings({
    required this.biometricEnabled,
    required this.twoFactorEnabled,
  });

  Map<String, dynamic> toJson() => {
        'biometric_enabled': biometricEnabled,
        'two_factor_enabled': twoFactorEnabled,
      };

  static SecuritySettings fromJson(Map<String, dynamic> json) {
    return SecuritySettings(
      biometricEnabled: (json['biometric_enabled'] as bool?) ?? false,
      twoFactorEnabled: (json['two_factor_enabled'] as bool?) ?? false,
    );
  }
}

class SecurityProvider extends ChangeNotifier {
  static const _settingsKey = 'smartlink_security_settings_json';
  static const _pinKey = 'smartlink_transaction_pin_plain';

  bool _loaded = false;
  SecuritySettings _settings = const SecuritySettings(biometricEnabled: false, twoFactorEnabled: false);
  String? _pin;

  bool get isLoaded => _loaded;
  SecuritySettings get settings => _settings;
  bool get hasPin => (_pin?.isNotEmpty ?? false);

  SecurityProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsRaw = prefs.getString(_settingsKey);
    final pinRaw = prefs.getString(_pinKey);

    if (settingsRaw != null && settingsRaw.isNotEmpty) {
      try {
        _settings = SecuritySettings.fromJson((jsonDecode(settingsRaw) as Map).cast<String, dynamic>());
      } catch (_) {
        _settings = const SecuritySettings(biometricEnabled: false, twoFactorEnabled: false);
      }
    }

    _pin = (pinRaw != null && pinRaw.isNotEmpty) ? pinRaw : null;
    _loaded = true;
    notifyListeners();
  }

  Future<void> updateSettings({
    bool? biometricEnabled,
    bool? twoFactorEnabled,
  }) async {
    _settings = SecuritySettings(
      biometricEnabled: biometricEnabled ?? _settings.biometricEnabled,
      twoFactorEnabled: twoFactorEnabled ?? _settings.twoFactorEnabled,
    );
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(_settings.toJson()));
  }

  Future<void> setPin({
    required String newPin,
    String? oldPin,
  }) async {
    if (newPin.length < 4 || newPin.length > 10) {
      throw Exception('PIN must be 4–10 digits.');
    }
    if (_pin != null && (_pin!.isNotEmpty) && (oldPin == null || oldPin.isEmpty)) {
      throw Exception('Old PIN required.');
    }
    if (_pin != null && oldPin != null && _pin != oldPin) {
      throw Exception('Old PIN is incorrect.');
    }

    _pin = newPin;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, newPin);
  }

  Future<bool> verifyPin(String pin) async {
    if (_pin == null) return true;
    return _pin == pin;
  }

  Future<void> clearPin() async {
    _pin = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
  }
}

