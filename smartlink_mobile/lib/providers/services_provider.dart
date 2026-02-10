import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SmartlinkServiceCategory {
  final int id;
  final String name;
  final String icon;

  const SmartlinkServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
  });

  static SmartlinkServiceCategory fromJson(Map<String, dynamic> json) {
    return SmartlinkServiceCategory(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      icon: (json['icon'] as String?) ?? 'home_repair_service',
    );
  }
}

class SmartlinkServiceMerchant {
  final int id;
  final String fullName;
  final bool trusted;
  final bool identityVerified;
  final double? ratingAvg;
  final List<Map<String, dynamic>> coverageAreas;

  const SmartlinkServiceMerchant({
    required this.id,
    required this.fullName,
    required this.trusted,
    required this.identityVerified,
    required this.ratingAvg,
    required this.coverageAreas,
  });

  static SmartlinkServiceMerchant fromJson(Map<String, dynamic> json) {
    return SmartlinkServiceMerchant(
      id: (json['id'] as num).toInt(),
      fullName: (json['full_name'] as String?) ?? '',
      trusted: (json['trusted'] as bool?) ?? false,
      identityVerified: (json['identity_verified'] as bool?) ?? false,
      ratingAvg: (json['rating_avg'] as num?)?.toDouble(),
      coverageAreas: ((json['coverage_areas'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList(growable: false),
    );
  }
}

class SmartlinkService {
  final int id;
  final int categoryId;
  final String title;
  final String description;
  final String pricingType;
  final SmartlinkServiceMerchant merchant;

  const SmartlinkService({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.pricingType,
    required this.merchant,
  });

  static SmartlinkService fromJson(Map<String, dynamic> json) {
    return SmartlinkService(
      id: (json['id'] as num).toInt(),
      categoryId: (json['category_id'] as num).toInt(),
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      pricingType: (json['pricing_type'] as String?) ?? 'quote',
      merchant: SmartlinkServiceMerchant.fromJson(
        (json['merchant'] as Map).cast<String, dynamic>(),
      ),
    );
  }
}

class ServicesProvider extends ChangeNotifier {
  bool _isLoading = true;
  List<SmartlinkServiceCategory> _categories = const [];
  List<SmartlinkService> _services = const [];

  bool get isLoading => _isLoading;
  List<SmartlinkServiceCategory> get categories => List.unmodifiable(_categories);
  List<SmartlinkService> get services => List.unmodifiable(_services);

  ServicesProvider() {
    load();
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      final raw = await rootBundle.loadString('assets/mock_data/services.json');
      final decoded = (jsonDecode(raw) as Map<String, dynamic>);
      final cats = (decoded['categories'] as List).cast<Map<String, dynamic>>();
      final serv = (decoded['services'] as List).cast<Map<String, dynamic>>();

      _categories = cats.map(SmartlinkServiceCategory.fromJson).toList(growable: false);
      _services = serv.map(SmartlinkService.fromJson).toList(growable: false);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  SmartlinkService? byId(int id) {
    try {
      return _services.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}

