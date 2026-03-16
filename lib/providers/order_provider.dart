import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_model.dart';
import '../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  static const String _orderStorageKey = 'orders_v1';

  final List<OrderModel> _orders = <OrderModel>[];

  List<OrderModel> get orders => List<OrderModel>.unmodifiable(_orders);

  List<OrderModel> ordersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList(growable: false);
  }

  Future<void> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_orderStorageKey);
    if (raw == null || raw.isEmpty) {
      return;
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    _orders
      ..clear()
      ..addAll(
        decoded.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)),
      );
    notifyListeners();
  }

  Future<OrderModel> placeOrder({
    required List<CartItemModel> items,
    required String address,
    required PaymentMethod paymentMethod,
  }) async {
    final now = DateTime.now();
    final normalizedItems = items
        .map(
          (item) => item.copyWith(
            product: item.product,
            quantity: item.quantity,
            selected: false,
            selectedSize: item.selectedSize,
            selectedColor: item.selectedColor,
          ),
        )
        .toList(growable: false);

    final order = OrderModel(
      id: 'DH${now.microsecondsSinceEpoch}',
      items: normalizedItems,
      address: address,
      paymentMethod: paymentMethod,
      status: OrderStatus.pending,
      createdAt: now,
    );

    _orders.insert(0, order);
    await _saveOrders();
    notifyListeners();
    return order;
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _orders.map((e) => e.toJson()).toList(growable: false);
    await prefs.setString(_orderStorageKey, jsonEncode(payload));
  }
}