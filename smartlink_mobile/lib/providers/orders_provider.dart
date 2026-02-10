import 'dart:math';

import 'package:flutter/foundation.dart';

import 'cart_provider.dart';

enum SmartlinkOrderStatus {
  placed('placed'),
  paid('paid'),
  acceptedBySeller('accepted_by_seller'),
  dispatching('dispatching'),
  assignedToRider('assigned_to_rider'),
  pickedUp('picked_up'),
  delivered('delivered'),
  confirmed('confirmed'),
  cancelled('cancelled'),
  disputed('disputed');

  final String value;
  const SmartlinkOrderStatus(this.value);

  static SmartlinkOrderStatus fromValue(String value) {
    return SmartlinkOrderStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => SmartlinkOrderStatus.placed,
    );
  }
}

class SmartlinkOrderItem {
  final String productId;
  final String title;
  final String imageUrl;
  final double unitPrice;
  final int quantity;

  const SmartlinkOrderItem({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
  });

  double get total => unitPrice * quantity;
}

class SmartlinkOrder {
  final String id;
  final DateTime createdAt;
  SmartlinkOrderStatus status;

  final String shopName;
  final List<SmartlinkOrderItem> items;
  final double deliveryFee;

  SmartlinkOrder({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.shopName,
    required this.items,
    required this.deliveryFee,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);
  double get total => subtotal + deliveryFee;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}

class OrdersProvider extends ChangeNotifier {
  final List<SmartlinkOrder> _orders = [];
  final _random = Random();

  List<SmartlinkOrder> get orders => List.unmodifiable(_orders);

  SmartlinkOrder? byId(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  SmartlinkOrder createFromCart({
    required List<CartItem> cartItems,
    required String shopName,
    required double deliveryFee,
  }) {
    final orderId =
        'SL-${DateTime.now().millisecondsSinceEpoch}-${_random.nextInt(9999).toString().padLeft(4, '0')}';

    final order = SmartlinkOrder(
      id: orderId,
      createdAt: DateTime.now(),
      status: SmartlinkOrderStatus.paid,
      shopName: shopName,
      deliveryFee: deliveryFee,
      items: cartItems
          .map(
            (item) => SmartlinkOrderItem(
              productId: item.productId,
              title: item.productTitle,
              imageUrl: item.productImage,
              unitPrice: item.price,
              quantity: item.quantity,
            ),
          )
          .toList(growable: false),
    );

    _orders.insert(0, order);
    notifyListeners();
    return order;
  }

  void setStatus(String orderId, SmartlinkOrderStatus status) {
    final order = byId(orderId);
    if (order == null) return;
    order.status = status;
    notifyListeners();
  }

  void advanceStatus(String orderId) {
    final order = byId(orderId);
    if (order == null) return;

    final current = order.status;
    final next = switch (current) {
      SmartlinkOrderStatus.placed => SmartlinkOrderStatus.paid,
      SmartlinkOrderStatus.paid => SmartlinkOrderStatus.acceptedBySeller,
      SmartlinkOrderStatus.acceptedBySeller => SmartlinkOrderStatus.dispatching,
      SmartlinkOrderStatus.dispatching => SmartlinkOrderStatus.assignedToRider,
      SmartlinkOrderStatus.assignedToRider => SmartlinkOrderStatus.pickedUp,
      SmartlinkOrderStatus.pickedUp => SmartlinkOrderStatus.delivered,
      SmartlinkOrderStatus.delivered => SmartlinkOrderStatus.confirmed,
      SmartlinkOrderStatus.confirmed => SmartlinkOrderStatus.confirmed,
      SmartlinkOrderStatus.cancelled => SmartlinkOrderStatus.cancelled,
      SmartlinkOrderStatus.disputed => SmartlinkOrderStatus.disputed,
    };

    order.status = next;
    notifyListeners();
  }
}

