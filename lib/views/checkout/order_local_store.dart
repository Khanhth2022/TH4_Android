import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/cart_model.dart';

class CheckoutPaymentMethod {
  static const String cod = 'cod';
  static const String momo = 'momo';

  static String toDisplayName(String value) {
    switch (value) {
      case cod:
        return 'COD';
      case momo:
        return 'Momo';
      default:
        return value;
    }
  }
}

class CheckoutOrderStatus {
  static const String pending = 'pending';
  static const String shipping = 'shipping';
  static const String delivered = 'delivered';
  static const String canceled = 'canceled';

  static String toDisplayName(String value) {
    switch (value) {
      case pending:
        return 'Chờ xác nhận';
      case shipping:
        return 'Đang giao';
      case delivered:
        return 'Đã giao';
      case canceled:
        return 'Đã hủy';
      default:
        return value;
    }
  }
}

class CheckoutOrder {
  CheckoutOrder({
    required this.id,
    required this.createdAt,
    required this.address,
    required this.paymentMethod,
    required this.status,
    required this.items,
    required this.totalAmount,
  });

  final String id;
  final DateTime createdAt;
  final String address;
  final String paymentMethod;
  final String status;
  final List<CartItemModel> items;
  final double totalAmount;

  factory CheckoutOrder.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();

    return CheckoutOrder(
      id: (json['id'] as String?) ?? '',
      createdAt:
          DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
      address: (json['address'] as String?) ?? '',
      paymentMethod:
          (json['paymentMethod'] as String?) ?? CheckoutPaymentMethod.cod,
      status: (json['status'] as String?) ?? CheckoutOrderStatus.pending,
      items: rawItems.map(CartItemModel.fromJson).toList(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'address': address,
      'paymentMethod': paymentMethod,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
    };
  }
}

class OrderLocalStore {
  static const String _orderStorageKey = 'checkout_orders_v1';

  static Future<List<CheckoutOrder>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_orderStorageKey);
    if (raw == null || raw.isEmpty) {
      return <CheckoutOrder>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    final orders = decoded
        .map((item) => CheckoutOrder.fromJson(item as Map<String, dynamic>))
        .toList();

    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  static Future<void> addOrder(CheckoutOrder newOrder) async {
    final orders = await getOrders();
    orders.insert(0, newOrder);

    final prefs = await SharedPreferences.getInstance();
    final payload = orders.map((order) => order.toJson()).toList();
    await prefs.setString(_orderStorageKey, jsonEncode(payload));
  }
}
