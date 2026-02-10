import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmartlinkAddress {
  final String id;
  final String? label;
  final String addressText;
  final String? city;
  final String? state;
  final String countryCode;
  final bool isDefault;

  const SmartlinkAddress({
    required this.id,
    required this.label,
    required this.addressText,
    required this.city,
    required this.state,
    required this.countryCode,
    required this.isDefault,
  });

  SmartlinkAddress copyWith({
    String? id,
    String? label,
    String? addressText,
    String? city,
    String? state,
    String? countryCode,
    bool? isDefault,
  }) {
    return SmartlinkAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      addressText: addressText ?? this.addressText,
      city: city ?? this.city,
      state: state ?? this.state,
      countryCode: countryCode ?? this.countryCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'address_text': addressText,
        'city': city,
        'state': state,
        'country_code': countryCode,
        'is_default': isDefault,
      };

  static SmartlinkAddress fromJson(Map<String, dynamic> json) {
    return SmartlinkAddress(
      id: (json['id'] as String?) ?? '',
      label: json['label'] as String?,
      addressText: (json['address_text'] as String?) ?? '',
      city: json['city'] as String?,
      state: json['state'] as String?,
      countryCode: (json['country_code'] as String?) ?? 'NG',
      isDefault: (json['is_default'] as bool?) ?? false,
    );
  }
}

class AddressProvider extends ChangeNotifier {
  static const _prefsKey = 'smartlink_addresses_json';

  List<SmartlinkAddress> _items = const [];
  bool _loaded = false;

  List<SmartlinkAddress> get items => List.unmodifiable(_items);
  bool get isLoaded => _loaded;

  SmartlinkAddress? get defaultAddress {
    try {
      return _items.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _items.isEmpty ? null : _items.first;
    }
  }

  AddressProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      _items = const [];
      _loaded = true;
      notifyListeners();
      return;
    }

    try {
      final decoded = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _items = decoded.map(SmartlinkAddress.fromJson).toList(growable: false);
    } catch (_) {
      _items = const [];
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_items.map((e) => e.toJson()).toList(growable: false));
    await prefs.setString(_prefsKey, raw);
  }

  Future<void> upsert(SmartlinkAddress address) async {
    final existingIndex = _items.indexWhere((a) => a.id == address.id);
    var next = [..._items];

    if (address.isDefault) {
      next = next.map((a) => a.copyWith(isDefault: false)).toList(growable: false);
    }

    if (existingIndex == -1) {
      next.insert(0, address);
    } else {
      next[existingIndex] = address;
    }

    if (next.isNotEmpty && next.every((a) => !a.isDefault)) {
      next[0] = next[0].copyWith(isDefault: true);
    }

    _items = next;
    notifyListeners();
    await _persist();
  }

  Future<void> remove(String id) async {
    var next = _items.where((a) => a.id != id).toList(growable: false);
    if (next.isNotEmpty && next.every((a) => !a.isDefault)) {
      next[0] = next[0].copyWith(isDefault: true);
    }
    _items = next;
    notifyListeners();
    await _persist();
  }

  Future<void> setDefault(String id) async {
    final next = _items
        .map((a) => a.copyWith(isDefault: a.id == id))
        .toList(growable: false);
    _items = next;
    notifyListeners();
    await _persist();
  }
}

