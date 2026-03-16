import 'cart_model.dart';

enum PaymentMethod { cod, momo }

extension PaymentMethodX on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cod:
        return 'COD';
      case PaymentMethod.momo:
        return 'Momo';
    }
  }
}

enum OrderStatus { pending, shipping, delivered, cancelled }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.shipping:
        return 'Đang giao';
      case OrderStatus.delivered:
        return 'Đã giao';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }
}

class OrderModel {
  OrderModel({
    required this.id,
    required this.items,
    required this.address,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final List<CartItemModel> items;
  final String address;
  final PaymentMethod paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;

  int get totalUnits => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => items.fold(0, (sum, item) => sum + item.subtotal);

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: (json['id'] ?? '') as String,
      items: ((json['items'] as List<dynamic>?) ?? const <dynamic>[])
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      address: (json['address'] ?? '') as String,
      paymentMethod: PaymentMethod.values.firstWhere(
        (method) => method.name == (json['paymentMethod'] ?? ''),
        orElse: () => PaymentMethod.cod,
      ),
      status: OrderStatus.values.firstWhere(
        (orderStatus) => orderStatus.name == (json['status'] ?? ''),
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '') as String) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(growable: false),
      'address': address,
      'paymentMethod': paymentMethod.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}