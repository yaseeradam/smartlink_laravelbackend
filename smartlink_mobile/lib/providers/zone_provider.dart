import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmartlinkZone {
  final String id;
  final String name;

  const SmartlinkZone({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  static SmartlinkZone fromJson(Map<String, dynamic> json) {
    return SmartlinkZone(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
    );
  }
}

class ZoneProvider extends ChangeNotifier {
  static const _homePrefsKey = 'smartlink_selected_home_zone_json';
  static const _operationalPrefsKey = 'smartlink_selected_operational_zone_json';

  final List<SmartlinkZone> _zones = const [
    SmartlinkZone(id: 'zone_ikeja', name: 'Ikeja, Lagos'),
    SmartlinkZone(id: 'zone_yaba', name: 'Yaba, Lagos'),
    SmartlinkZone(id: 'zone_surulere', name: 'Surulere, Lagos'),
    SmartlinkZone(id: 'zone_victoria_island', name: 'Victoria Island, Lagos'),
    SmartlinkZone(id: 'zone_lekki', name: 'Lekki, Lagos'),
  ];

  SmartlinkZone? _selectedHomeZone;
  SmartlinkZone? _selectedOperationalZone;

  List<SmartlinkZone> get zones => List.unmodifiable(_zones);
  SmartlinkZone? get selectedZone => _selectedHomeZone;
  String get selectedZoneLabel => _selectedHomeZone?.name ?? 'Select your zone';

  SmartlinkZone? get operationalZone => _selectedOperationalZone;
  String get operationalZoneLabel =>
      _selectedOperationalZone?.name ?? 'Select operational zone';

  ZoneProvider() {
    _loadSelectedZones();
  }

  Future<void> _loadSelectedZones() async {
    final prefs = await SharedPreferences.getInstance();
    final homeRaw = prefs.getString(_homePrefsKey);
    final operationalRaw = prefs.getString(_operationalPrefsKey);

    _selectedHomeZone = _zoneFromRaw(homeRaw) ?? _zones.first;
    _selectedOperationalZone = _zoneFromRaw(operationalRaw);

    notifyListeners();
  }

  SmartlinkZone? _zoneFromRaw(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final zone = SmartlinkZone.fromJson(json);
      return _zones.firstWhere(
        (z) => z.id == zone.id,
        orElse: () => _zones.first,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> setSelectedZone(SmartlinkZone zone) async {
    _selectedHomeZone = zone;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_homePrefsKey, jsonEncode(zone.toJson()));
  }

  Future<void> setOperationalZone(SmartlinkZone zone) async {
    _selectedOperationalZone = zone;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_operationalPrefsKey, jsonEncode(zone.toJson()));
  }
}
