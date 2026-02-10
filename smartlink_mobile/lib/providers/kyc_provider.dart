import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SmartlinkKycType {
  buyerBasic('buyer_basic'),
  seller('seller'),
  rider('rider');

  final String value;
  const SmartlinkKycType(this.value);

  static SmartlinkKycType fromValue(String value) {
    return SmartlinkKycType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => SmartlinkKycType.buyerBasic,
    );
  }
}

enum SmartlinkKycStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  final String value;
  const SmartlinkKycStatus(this.value);

  static SmartlinkKycStatus fromValue(String value) {
    return SmartlinkKycStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => SmartlinkKycStatus.pending,
    );
  }
}

class SmartlinkKycDocument {
  final String docType;
  final String localPath;

  const SmartlinkKycDocument({
    required this.docType,
    required this.localPath,
  });

  Map<String, dynamic> toJson() => {
        'doc_type': docType,
        'local_path': localPath,
      };

  static SmartlinkKycDocument fromJson(Map<String, dynamic> json) {
    return SmartlinkKycDocument(
      docType: (json['doc_type'] as String?) ?? 'document',
      localPath: (json['local_path'] as String?) ?? '',
    );
  }
}

class SmartlinkKycRequest {
  final String id;
  final SmartlinkKycType type;
  SmartlinkKycStatus status;
  final DateTime submittedAt;
  final String? rejectionReason;
  final Map<String, dynamic> meta;
  final List<SmartlinkKycDocument> documents;

  SmartlinkKycRequest({
    required this.id,
    required this.type,
    required this.status,
    required this.submittedAt,
    required this.rejectionReason,
    required this.meta,
    required this.documents,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'kyc_type': type.value,
        'status': status.value,
        'submitted_at': submittedAt.toIso8601String(),
        'rejection_reason': rejectionReason,
        'meta': meta,
        'documents': documents.map((d) => d.toJson()).toList(growable: false),
      };

  static SmartlinkKycRequest fromJson(Map<String, dynamic> json) {
    return SmartlinkKycRequest(
      id: (json['id'] as String?) ?? '',
      type: SmartlinkKycType.fromValue((json['kyc_type'] as String?) ?? 'buyer_basic'),
      status: SmartlinkKycStatus.fromValue((json['status'] as String?) ?? 'pending'),
      submittedAt: DateTime.tryParse((json['submitted_at'] as String?) ?? '') ?? DateTime.now(),
      rejectionReason: json['rejection_reason'] as String?,
      meta: (json['meta'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
      documents: ((json['documents'] as List?) ?? const [])
          .whereType<Map>()
          .map((m) => SmartlinkKycDocument.fromJson(m.cast<String, dynamic>()))
          .toList(growable: false),
    );
  }
}

class KycProvider extends ChangeNotifier {
  static const _prefsKey = 'smartlink_kyc_requests_json';

  List<SmartlinkKycRequest> _requests = const [];
  bool _loaded = false;

  List<SmartlinkKycRequest> get requests => List.unmodifiable(_requests);
  bool get isLoaded => _loaded;
  SmartlinkKycRequest? get latest => _requests.isEmpty ? null : _requests.first;

  KycProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      _requests = const [];
      _loaded = true;
      notifyListeners();
      return;
    }

    try {
      final decoded = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _requests = decoded.map(SmartlinkKycRequest.fromJson).toList(growable: false);
    } catch (_) {
      _requests = const [];
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_requests.map((r) => r.toJson()).toList(growable: false));
    await prefs.setString(_prefsKey, raw);
  }

  Future<void> submit({
    required SmartlinkKycType type,
    required Map<String, dynamic> meta,
    required List<SmartlinkKycDocument> documents,
  }) async {
    final id = 'kyc_${DateTime.now().millisecondsSinceEpoch}';
    final request = SmartlinkKycRequest(
      id: id,
      type: type,
      status: SmartlinkKycStatus.pending,
      submittedAt: DateTime.now(),
      rejectionReason: null,
      meta: meta,
      documents: documents,
    );

    _requests = [request, ..._requests];
    notifyListeners();
    await _persist();
  }

  Future<void> simulateAdminDecision(String id, SmartlinkKycStatus status, {String? reason}) async {
    final next = _requests.map((r) {
      if (r.id != id) return r;
      r.status = status;
      return r;
    }).toList(growable: false);

    _requests = next;
    notifyListeners();
    await _persist();
  }
}

