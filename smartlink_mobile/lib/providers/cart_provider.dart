import 'package:flutter/material.dart';

class CartItem {
  final String productId;
  final String productTitle;
  final String productImage;
  final double price;
  int quantity;

  CartItem({
    required this.productId,
    required this.productTitle,
    required this.productImage,
    required this.price,
    this.quantity = 1,
  });

  double get total => price * quantity;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.total);

  double get deliveryFee => 500.0; // Mock delivery fee

  double get total => subtotal + deliveryFee;

  void addItem(Map<String, dynamic> product) {
    final existingIndex = _items.indexWhere(
      (item) => item.productId == product['id'],
    );

    final image = (product['image'] as String?) ??
        ((product['images'] is List && (product['images'] as List).isNotEmpty)
            ? (product['images'] as List).first as String?
            : null) ??
        '';

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(
        productId: product['id'],
        productTitle: product['title'],
        productImage: image,
        price: (product['price'] as num).toDouble(),
      ));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
