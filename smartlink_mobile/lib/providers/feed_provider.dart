import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum FeedType { nearYou, inYourState, acrossNigeria, forYou }

enum FeedScope { auto, local, state, national }

class FeedProvider extends ChangeNotifier {
  bool _isLoading = true;
  List<Map<String, dynamic>> _products = const [];

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get products => List.unmodifiable(_products);

  FeedProvider() {
    load();
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      final raw = await rootBundle.loadString('assets/mock_data/products.json');
      final decoded = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _products = decoded;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> items({
    required FeedType type,
    required String zoneLabel,
    required FeedScope scope,
    int limit = 50,
  }) {
    final (city, state) = _parseZone(zoneLabel);

    List<Map<String, dynamic>> localItems() {
      if (city.isEmpty && state.isEmpty) return _products;
      return _products.where((p) {
        final location = ((p['sellerLocation'] as String?) ?? '').toLowerCase();
        final cityOk = city.isEmpty || location.contains(city.toLowerCase());
        final stateOk = state.isEmpty || location.contains(state.toLowerCase());
        return cityOk && stateOk;
      }).toList(growable: false);
    }

    List<Map<String, dynamic>> stateItems() {
      if (state.isEmpty) return _products;
      return _products.where((p) {
        final location = ((p['sellerLocation'] as String?) ?? '').toLowerCase();
        return location.contains(state.toLowerCase());
      }).toList(growable: false);
    }

    List<Map<String, dynamic>> nationalItems() => _products;

    List<Map<String, dynamic>> result = switch (type) {
      FeedType.nearYou => localItems(),
      FeedType.inYourState => stateItems(),
      FeedType.acrossNigeria => nationalItems(),
      FeedType.forYou => switch (scope) {
          FeedScope.local => localItems(),
          FeedScope.state => stateItems(),
          FeedScope.national => nationalItems(),
          FeedScope.auto => _autoExpand(localItems(), stateItems(), nationalItems(), limit),
        },
    };

    result = _sorted(result);
    if (result.length > limit) return result.take(limit).toList(growable: false);
    return result;
  }

  static List<Map<String, dynamic>> _sorted(List<Map<String, dynamic>> items) {
    final copy = [...items];
    copy.sort((a, b) {
      final ar = (a['rating'] as num?)?.toDouble() ?? 0.0;
      final br = (b['rating'] as num?)?.toDouble() ?? 0.0;
      return br.compareTo(ar);
    });
    return copy;
  }

  static List<Map<String, dynamic>> _autoExpand(
    List<Map<String, dynamic>> local,
    List<Map<String, dynamic>> state,
    List<Map<String, dynamic>> national,
    int limit,
  ) {
    final seen = <String>{};
    final out = <Map<String, dynamic>>[];

    void addAll(Iterable<Map<String, dynamic>> source) {
      for (final p in source) {
        final id = (p['id'] as String?) ?? '';
        if (id.isEmpty || seen.contains(id)) continue;
        seen.add(id);
        out.add(p);
        if (out.length >= limit) return;
      }
    }

    addAll(local);
    if (out.length < limit) addAll(state);
    if (out.length < limit) addAll(national);
    return out;
  }

  static (String city, String state) _parseZone(String zoneLabel) {
    final parts = zoneLabel.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return ('', '');
    if (parts.length == 1) return (parts[0], '');
    return (parts[0], parts[1]);
  }
}

