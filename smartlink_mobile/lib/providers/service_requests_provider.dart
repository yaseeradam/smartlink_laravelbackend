import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ServiceRequestStatus {
  submitted('submitted'),
  accepted('accepted'),
  quoteSent('quote_sent'),
  awaitingCustomerApproval('awaiting_customer_approval'),
  approved('approved'),
  paymentHeld('payment_held'),
  scheduled('scheduled'),
  providerOnTheWay('provider_on_the_way'),
  workStarted('work_started'),
  workCompletedProvider('work_completed_provider'),
  awaitingCustomerConfirmation('awaiting_customer_confirmation'),
  completed('completed'),
  cancelled('cancelled'),
  issueReported('issue_reported'),
  disputed('disputed'),
  refunded('refunded');

  final String value;
  const ServiceRequestStatus(this.value);

  static ServiceRequestStatus fromValue(String value) {
    return ServiceRequestStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => ServiceRequestStatus.submitted,
    );
  }
}

class ServiceQuote {
  final int amount;
  final String note;
  final DateTime createdAt;

  const ServiceQuote({
    required this.amount,
    required this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'note': note,
        'created_at': createdAt.toIso8601String(),
      };

  static ServiceQuote fromJson(Map<String, dynamic> json) {
    return ServiceQuote(
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      note: (json['note'] as String?) ?? '',
      createdAt: DateTime.tryParse((json['created_at'] as String?) ?? '') ?? DateTime.now(),
    );
  }
}

class ServiceRequest {
  final String id;
  final int serviceId;
  final int addressLocalId;
  final String requestText;
  final DateTime createdAt;
  final DateTime? preferredDate;
  final String? preferredTimeWindow;
  final String urgency;

  ServiceRequestStatus status;
  ServiceQuote? latestQuote;
  bool contactUnlocked;
  String? contactToken;

  ServiceRequest({
    required this.id,
    required this.serviceId,
    required this.addressLocalId,
    required this.requestText,
    required this.createdAt,
    required this.preferredDate,
    required this.preferredTimeWindow,
    required this.urgency,
    required this.status,
    required this.latestQuote,
    required this.contactUnlocked,
    required this.contactToken,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'service_id': serviceId,
        'address_local_id': addressLocalId,
        'request_text': requestText,
        'created_at': createdAt.toIso8601String(),
        'preferred_date': preferredDate?.toIso8601String(),
        'preferred_time_window': preferredTimeWindow,
        'urgency': urgency,
        'status': status.value,
        'latest_quote': latestQuote?.toJson(),
        'contact_unlocked': contactUnlocked,
        'contact_token': contactToken,
      };

  static ServiceRequest fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: (json['id'] as String?) ?? '',
      serviceId: (json['service_id'] as num?)?.toInt() ?? 0,
      addressLocalId: (json['address_local_id'] as num?)?.toInt() ?? 0,
      requestText: (json['request_text'] as String?) ?? '',
      createdAt: DateTime.tryParse((json['created_at'] as String?) ?? '') ?? DateTime.now(),
      preferredDate: json['preferred_date'] == null
          ? null
          : DateTime.tryParse((json['preferred_date'] as String?) ?? ''),
      preferredTimeWindow: json['preferred_time_window'] as String?,
      urgency: (json['urgency'] as String?) ?? 'normal',
      status: ServiceRequestStatus.fromValue((json['status'] as String?) ?? 'submitted'),
      latestQuote: json['latest_quote'] is Map
          ? ServiceQuote.fromJson((json['latest_quote'] as Map).cast<String, dynamic>())
          : null,
      contactUnlocked: (json['contact_unlocked'] as bool?) ?? false,
      contactToken: json['contact_token'] as String?,
    );
  }
}

class ServiceRequestsProvider extends ChangeNotifier {
  static const _prefsKey = 'smartlink_service_requests_json';

  List<ServiceRequest> _items = const [];
  bool _loaded = false;

  List<ServiceRequest> get items => List.unmodifiable(_items);
  bool get isLoaded => _loaded;

  ServiceRequestsProvider() {
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
      _items = decoded.map(ServiceRequest.fromJson).toList(growable: false);
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

  ServiceRequest? byId(String id) {
    try {
      return _items.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<ServiceRequest> submit({
    required int serviceId,
    required int addressLocalId,
    required String requestText,
    DateTime? preferredDate,
    String? preferredTimeWindow,
    required String urgency,
  }) async {
    final id = 'sr_${DateTime.now().millisecondsSinceEpoch}';
    final req = ServiceRequest(
      id: id,
      serviceId: serviceId,
      addressLocalId: addressLocalId,
      requestText: requestText,
      createdAt: DateTime.now(),
      preferredDate: preferredDate,
      preferredTimeWindow: preferredTimeWindow,
      urgency: urgency,
      status: ServiceRequestStatus.submitted,
      latestQuote: null,
      contactUnlocked: false,
      contactToken: null,
    );

    _items = [req, ..._items];
    notifyListeners();
    await _persist();
    return req;
  }

  Future<void> simulateMerchantAccept(String id) async {
    final r = byId(id);
    if (r == null) return;
    r.status = ServiceRequestStatus.accepted;
    notifyListeners();
    await _persist();
  }

  Future<void> simulateSendQuote(String id, {required int amount, required String note}) async {
    final r = byId(id);
    if (r == null) return;
    r.latestQuote = ServiceQuote(amount: amount, note: note, createdAt: DateTime.now());
    r.status = ServiceRequestStatus.awaitingCustomerApproval;
    notifyListeners();
    await _persist();
  }

  Future<void> customerAcceptQuote(String id) async {
    final r = byId(id);
    if (r == null) return;
    if (r.status != ServiceRequestStatus.awaitingCustomerApproval) return;
    r.status = ServiceRequestStatus.approved;
    notifyListeners();
    await _persist();
  }

  Future<void> customerRejectQuote(String id) async {
    final r = byId(id);
    if (r == null) return;
    if (r.status != ServiceRequestStatus.awaitingCustomerApproval) return;
    r.status = ServiceRequestStatus.accepted;
    r.latestQuote = null;
    notifyListeners();
    await _persist();
  }

  Future<void> payHeld(String id, {required String contactToken}) async {
    final r = byId(id);
    if (r == null) return;
    if (r.status != ServiceRequestStatus.approved) return;
    r.status = ServiceRequestStatus.paymentHeld;
    r.contactUnlocked = true;
    r.contactToken = contactToken;
    notifyListeners();
    await _persist();
  }

  Future<void> advance(String id) async {
    final r = byId(id);
    if (r == null) return;

    final next = switch (r.status) {
      ServiceRequestStatus.submitted => ServiceRequestStatus.accepted,
      ServiceRequestStatus.accepted => ServiceRequestStatus.awaitingCustomerApproval,
      ServiceRequestStatus.quoteSent => ServiceRequestStatus.awaitingCustomerApproval,
      ServiceRequestStatus.awaitingCustomerApproval => ServiceRequestStatus.approved,
      ServiceRequestStatus.approved => ServiceRequestStatus.paymentHeld,
      ServiceRequestStatus.paymentHeld => ServiceRequestStatus.scheduled,
      ServiceRequestStatus.scheduled => ServiceRequestStatus.providerOnTheWay,
      ServiceRequestStatus.providerOnTheWay => ServiceRequestStatus.workStarted,
      ServiceRequestStatus.workStarted => ServiceRequestStatus.workCompletedProvider,
      ServiceRequestStatus.workCompletedProvider => ServiceRequestStatus.awaitingCustomerConfirmation,
      ServiceRequestStatus.awaitingCustomerConfirmation => ServiceRequestStatus.completed,
      ServiceRequestStatus.completed => ServiceRequestStatus.completed,
      ServiceRequestStatus.cancelled => ServiceRequestStatus.cancelled,
      ServiceRequestStatus.issueReported => ServiceRequestStatus.disputed,
      ServiceRequestStatus.disputed => ServiceRequestStatus.refunded,
      ServiceRequestStatus.refunded => ServiceRequestStatus.refunded,
    };

    r.status = next;
    notifyListeners();
    await _persist();
  }
}

