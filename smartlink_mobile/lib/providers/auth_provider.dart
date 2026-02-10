import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../core/utils/app_role.dart';

class AuthProvider extends ChangeNotifier {
  static const _tokenKey = 'smartlink_auth_token';
  static const _userKey = 'smartlink_auth_user_json';

  bool _isAuthenticated = false;
  Map<String, dynamic>? _currentUser;
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isPhoneVerified => (_currentUser?['phoneVerified'] as bool?) ?? false;
  String? get token => _token;

  Future<void> tryRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final rawUser = prefs.getString(_userKey);

    if (token == null || token.isEmpty || rawUser == null || rawUser.isEmpty) {
      return;
    }

    Map<String, dynamic>? cachedUser;
    try {
      cachedUser = (jsonDecode(rawUser) as Map).cast<String, dynamic>();
    } catch (_) {
      cachedUser = null;
    }

    _isAuthenticated = true;
    _token = token;
    ApiClient.instance.setToken(token);
    if (cachedUser != null) _currentUser = cachedUser;
    notifyListeners();

    try {
      final me = await ApiClient.instance.getJson('me');
      _currentUser = _normalizeUser(me);
      await _persist();
      notifyListeners();
    } on ApiException {
      // Keep cached session; API may be offline.
    }
  }

  Future<void> login({
    String? phone,
    String? email,
    required String password,
    AppRole? roleHint,
  }) async {
    final payload = <String, dynamic>{
      'password': password,
      'device_name': 'mobile',
    };
    if (phone != null && phone.trim().isNotEmpty) {
      payload['phone'] = phone.trim();
    } else if (email != null && email.trim().isNotEmpty) {
      payload['email'] = email.trim();
    }

    final data = await ApiClient.instance.postJson('auth/login', body: payload);
    final token = (data['token'] as String?) ?? '';
    final user = data['user'];

    if (token.isEmpty || user is! Map) {
      throw const ApiException('Invalid login response.');
    }

    _isAuthenticated = true;
    _token = token;
    ApiClient.instance.setToken(token);
    _currentUser = _normalizeUser(user.cast<String, dynamic>(), roleHint: roleHint);
    await _persist();
    notifyListeners();
  }

  Future<void> loginDemo({
    required AppRole role,
    String? identifier,
  }) async {
    final trimmed = (identifier ?? '').trim();
    final isEmail = trimmed.contains('@');
    final displayName = _demoName(role, trimmed, isEmail);
    final now = DateTime.now().toIso8601String();

    final user = <String, dynamic>{
      'id': 'demo_${role.apiValue}',
      'role': role.apiValue,
      'name': displayName,
      'full_name': displayName,
      'email': isEmail ? trimmed : '${role.apiValue}@demo.smartlink',
      'phone': !isEmail && trimmed.isNotEmpty ? trimmed : '+2348012345678',
      'phone_verified_at': now,
    };

    _isAuthenticated = true;
    _token = 'demo_${role.apiValue}_token';
    ApiClient.instance.setToken(_token);
    _currentUser = _normalizeUser(user, roleHint: role);
    await _persist();
    notifyListeners();
  }

  Future<void> logout() async {
    final token = _token;
    if (token != null && token.isNotEmpty) {
      try {
        await ApiClient.instance.postJson('auth/logout');
      } catch (_) {}
    }

    _isAuthenticated = false;
    _currentUser = null;
    _token = null;
    ApiClient.instance.setToken(null);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    notifyListeners();
  }

  Future<void> register({
    required String fullName,
    required String phone,
    String? email,
    required String password,
    required AppRole role,
  }) async {
    final payload = <String, dynamic>{
      'full_name': fullName.trim(),
      'phone': phone.trim(),
      'password': password,
      'role': role.apiValue,
      'device_name': 'mobile',
    };
    if (email != null && email.trim().isNotEmpty) payload['email'] = email.trim();

    final data = await ApiClient.instance.postJson('auth/register', body: payload);
    final token = (data['token'] as String?) ?? '';
    final user = data['user'];

    if (token.isEmpty || user is! Map) {
      throw const ApiException('Invalid registration response.');
    }

    _isAuthenticated = true;
    _token = token;
    ApiClient.instance.setToken(token);
    _currentUser = _normalizeUser(user.cast<String, dynamic>(), roleHint: role);
    await _persist();
    notifyListeners();
  }

  Future<void> registerDemo({
    required AppRole role,
    String? fullName,
    String? phone,
    String? email,
  }) async {
    final displayName = (fullName ?? '').trim();
    final name = displayName.isNotEmpty ? displayName : 'Demo ${role.label}';
    final trimmedPhone = (phone ?? '').trim();
    final trimmedEmail = (email ?? '').trim();
    final now = DateTime.now().toIso8601String();

    final user = <String, dynamic>{
      'id': 'demo_${role.apiValue}',
      'role': role.apiValue,
      'name': name,
      'full_name': name,
      'email': trimmedEmail.isNotEmpty ? trimmedEmail : '${role.apiValue}@demo.smartlink',
      'phone': trimmedPhone.isNotEmpty ? trimmedPhone : '+2348012345678',
      'phone_verified_at': now,
    };

    _isAuthenticated = true;
    _token = 'demo_${role.apiValue}_token';
    ApiClient.instance.setToken(_token);
    _currentUser = _normalizeUser(user, roleHint: role);
    await _persist();
    notifyListeners();
  }

  void markPhoneVerified() {
    if (_currentUser == null) return;
    _currentUser = {..._currentUser!, 'phoneVerified': true};
    unawaited(_persist());
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final token = _token;
    final user = _currentUser;

    if (token == null || token.isEmpty || user == null) return;
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user));
  }

  Map<String, dynamic> _normalizeUser(
    Map<String, dynamic> raw, {
    AppRole? roleHint,
  }) {
    final role = (raw['role'] as String?) ?? (roleHint?.apiValue ?? AppRole.customer.apiValue);
    final fullName = (raw['full_name'] as String?) ?? (raw['name'] as String?) ?? '';
    final phoneVerifiedAt = (raw['phone_verified_at'] as String?);

    return {
      ...raw,
      'name': fullName,
      'full_name': fullName,
      'role': role,
      'phoneVerified': phoneVerifiedAt != null && phoneVerifiedAt.isNotEmpty,
    };
  }

  String _demoName(AppRole role, String identifier, bool isEmail) {
    if (identifier.isEmpty || !isEmail) {
      return 'Demo ${role.label}';
    }
    final namePart = identifier.split('@').first.trim();
    if (namePart.isEmpty) return 'Demo ${role.label}';
    final head = namePart.substring(0, 1).toUpperCase();
    final tail = namePart.length > 1 ? namePart.substring(1) : '';
    return '$head$tail';
  }
}
