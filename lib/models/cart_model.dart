import 'product_model.dart';

class CartItemModel {
  CartItemModel({
    required this.product,
    this.quantity = 1,
    this.selected = true,
    this.selectedSize = 'M',
    this.selectedColor = 'Đỏ',
  });

  final ProductModel product;
  int quantity;
  bool selected;
  String selectedSize;
  String selectedColor;

  double get subtotal => product.price * quantity;

  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
    bool? selected,
    String? selectedSize,
    String? selectedColor,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selected: selected ?? this.selected,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(
        (json['product'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      selected: (json['selected'] as bool?) ?? true,
      selectedSize: (json['selectedSize'] ?? 'M') as String,
      selectedColor: (json['selectedColor'] ?? 'Đỏ') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'selected': selected,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
    };
  }
}
