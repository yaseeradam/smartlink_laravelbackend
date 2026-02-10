import 'package:flutter/material.dart';

class WalletProvider extends ChangeNotifier {
  double _balance = 4250.00; // Mock balance from HTML design
  final List<Map<String, dynamic>> _transactions = [];
  final List<Map<String, dynamic>> _escrowHolds = [];

  double get balance => _balance;
  List<Map<String, dynamic>> get transactions => _transactions;
  List<Map<String, dynamic>> get escrowHolds => _escrowHolds;

  Future<void> topUp(double amount) async {
    await Future.delayed(const Duration(seconds: 1));
    _balance += amount;
    _transactions.insert(0, {
      'id': 'txn_${DateTime.now().millisecondsSinceEpoch}',
      'type': 'topup',
      'amount': amount,
      'date': DateTime.now(),
      'status': 'completed',
    });
    notifyListeners();
  }

  Future<void> withdraw(double amount) async {
    if (amount > _balance) {
      throw Exception('Insufficient balance');
    }
    await Future.delayed(const Duration(seconds: 1));
    _balance -= amount;
    _transactions.insert(0, {
      'id': 'txn_${DateTime.now().millisecondsSinceEpoch}',
      'type': 'withdrawal',
      'amount': amount,
      'date': DateTime.now(),
      'status': 'completed',
    });
    notifyListeners();
  }

  Future<void> holdInEscrow(String orderId, double amount) async {
    if (amount > _balance) {
      throw Exception('Insufficient balance');
    }
    _balance -= amount;
    _escrowHolds.add({
      'id': 'escrow_${DateTime.now().millisecondsSinceEpoch}',
      'orderId': orderId,
      'amount': amount,
      'heldAt': DateTime.now(),
      'expiresAt': DateTime.now().add(const Duration(hours: 48)),
      'status': 'held',
    });
    notifyListeners();
  }

  Future<void> releaseEscrow(String orderId) async {
    final escrowIndex = _escrowHolds.indexWhere((e) => e['orderId'] == orderId);
    if (escrowIndex >= 0) {
      _escrowHolds[escrowIndex]['status'] = 'released';
      notifyListeners();
    }
  }

  Future<void> refundEscrow(String orderId) async {
    final escrowIndex = _escrowHolds.indexWhere((e) => e['orderId'] == orderId);
    if (escrowIndex >= 0) {
      final amount = _escrowHolds[escrowIndex]['amount'] as double;
      _balance += amount;
      _escrowHolds[escrowIndex]['status'] = 'refunded';
      notifyListeners();
    }
  }
}
