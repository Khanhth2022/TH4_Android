import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../services/cart_firestore_service.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({CartFirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? CartFirestoreService();

  static const String _cartStorageKey = 'cart_items_v1';

  final CartFirestoreService _firestoreService;
  final List<CartItemModel> _items = <CartItemModel>[];
  String? _userId;
  int _syncVersion = 0;

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

  void bindUser(String? userId) {
    if (_userId == userId) {
      return;
    }

    _userId = userId;
    _syncVersion += 1;
    final int currentSync = _syncVersion;
    _syncForCurrentUser(currentSync);
  }

  Future<void> loadCart() async {
    if (_userId != null) {
      await _loadFromFirestore(_userId!);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cartStorageKey);
    if (raw == null || raw.isEmpty) {
      _items.clear();
      notifyListeners();
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

    notifyListeners();
    await _persistChanges();
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= _items.length) {
      return;
    }
    _items.removeAt(index);
    notifyListeners();
    await _persistChanges();
  }

  Future<void> removeByProduct(int productId) async {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
    await _persistChanges();
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
    notifyListeners();
    await _persistChanges();
  }

  Future<void> increaseQty(int index) async {
    if (index < 0 || index >= _items.length) {
      return;
    }
    _items[index].quantity += 1;
    notifyListeners();
    await _persistChanges();
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
    notifyListeners();
    await _persistChanges();
  }

  Future<void> toggleItemSelection(int index, bool? selected) async {
    if (index < 0 || index >= _items.length) {
      return;
    }
    _items[index].selected = selected ?? false;
    notifyListeners();
    await _persistChanges();
  }

  Future<void> toggleSelectAll(bool selected) async {
    for (final item in _items) {
      item.selected = selected;
    }
    notifyListeners();
    await _persistChanges();
  }

  Future<void> clearSelected() async {
    _items.removeWhere((item) => item.selected);
    notifyListeners();
    await _persistChanges();
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

    notifyListeners();
    await _persistChanges();
  }

  Future<void> clearAll() async {
    _items.clear();
    notifyListeners();
    await _persistChanges();
  }

  Future<void> _persistChanges() async {
    try {
      await _saveCart();
    } catch (e, stackTrace) {
      // Keep UI responsive even if persistence fails temporarily.
      debugPrint('Cart persistence failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _saveCart() async {
    if (_userId != null) {
      await _firestoreService.saveCart(_userId!, _items);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final payload = _items.map((e) => e.toJson()).toList(growable: false);
    await prefs.setString(_cartStorageKey, jsonEncode(payload));
  }

  Future<void> _syncForCurrentUser(int syncVersion) async {
    if (_userId == null) {
      _items.clear();
      notifyListeners();
      return;
    }

    final String uid = _userId!;
    await _loadFromFirestore(uid);

    if (syncVersion != _syncVersion) {
      return;
    }
  }

  Future<void> _loadFromFirestore(String uid) async {
    try {
      final remoteItems = await _firestoreService.fetchCart(uid);
      _items
        ..clear()
        ..addAll(remoteItems);
      notifyListeners();
    } catch (_) {
      _items.clear();
      notifyListeners();
    }
  }
}
