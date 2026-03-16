import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  static const String _cartStorageKey = 'cart_items_v1';

  final List<CartItemModel> _items = <CartItemModel>[];

  List<CartItemModel> get items => List<CartItemModel>.unmodifiable(_items);

  int get itemTypesCount => _items.length;

  int get totalUnits => _items.fold(0, (sum, item) => sum + item.quantity);

  bool get isSelectAll => _items.isNotEmpty && _items.every((e) => e.selected);

  List<CartItemModel> get selectedItems =>
      _items.where((e) => e.selected).toList(growable: false);

  double get selectedTotalPrice {
    return _items
        .where((item) => item.selected)
        .fold(0, (sum, item) => sum + item.subtotal);
  }

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cartStorageKey);
    if (raw == null || raw.isEmpty) {
      return;
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    _items
      ..clear()
      ..addAll(
        decoded.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>)),
      );
    notifyListeners();
  }

  Future<void> addToCart(
    ProductModel product, {
    int quantity = 1,
    String size = 'M',
    String color = 'Đỏ',
  }) async {
    final index = _items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedSize == size &&
          item.selectedColor == color,
    );

    if (index == -1) {
      _items.add(
        CartItemModel(
          product: product,
          quantity: quantity,
          selected: true,
          selectedSize: size,
          selectedColor: color,
        ),
      );
    } else {
      _items[index].quantity += quantity;
      _items[index].selected = true;
    }

    await _saveCart();
    notifyListeners();
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= _items.length) {
      return;
    }
    _items.removeAt(index);
    await _saveCart();
    notifyListeners();
  }

  Future<void> removeByProduct(int productId) async {
    _items.removeWhere((item) => item.product.id == productId);
    await _saveCart();
    notifyListeners();
  }

  Future<void> updateQuantity(int index, int newQuantity) async {
    if (index < 0 || index >= _items.length) {
      return;
    }
    if (newQuantity <= 0) {
      await removeAt(index);
      return;
    }

    _items[index].quantity = newQuantity;
    await _saveCart();
    notifyListeners();
  }

  Future<void> increaseQty(int index) async {
    if (index < 0 || index >= _items.length) {
      return;
    }
    _items[index].quantity += 1;
    await _saveCart();
    notifyListeners();
  }

  Future<void> decreaseQty(int index) async {
    if (index < 0 || index >= _items.length) {
      return;
    }
    final current = _items[index].quantity;
    if (current <= 1) {
      await removeAt(index);
      return;
    }
    _items[index].quantity = current - 1;
    await _saveCart();
    notifyListeners();
  }

  Future<void> toggleItemSelection(int index, bool? selected) async {
    if (index < 0 || index >= _items.length) {
      return;
    }
    _items[index].selected = selected ?? false;
    await _saveCart();
    notifyListeners();
  }

  Future<void> toggleSelectAll(bool selected) async {
    for (final item in _items) {
      item.selected = selected;
    }
    await _saveCart();
    notifyListeners();
  }

  Future<void> clearSelected() async {
    _items.removeWhere((item) => item.selected);
    await _saveCart();
    notifyListeners();
  }

  Future<void> removeItems(List<CartItemModel> itemsToRemove) async {
    if (itemsToRemove.isEmpty) {
      return;
    }

    _items.removeWhere((item) {
      return itemsToRemove.any(
        (target) =>
            target.product.id == item.product.id &&
            target.selectedSize == item.selectedSize &&
            target.selectedColor == item.selectedColor,
      );
    });

    await _saveCart();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _items.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartStorageKey);
    notifyListeners();
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _items.map((e) => e.toJson()).toList(growable: false);
    await prefs.setString(_cartStorageKey, jsonEncode(payload));
  }
}
