import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cart_model.dart';

class CartFirestoreService {
  CartFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _primaryDoc(String uid) {
    return _firestore.collection('carts').doc(uid);
  }

  DocumentReference<Map<String, dynamic>> _legacyDoc(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc('state');
  }

  Future<List<CartItemModel>> fetchCart(String uid) async {
    var snapshot = await _primaryDoc(uid).get();
    if (!snapshot.exists) {
      // Backward compatibility for data written by old path.
      snapshot = await _legacyDoc(uid).get();
      if (!snapshot.exists) {
        return <CartItemModel>[];
      }
    }

    final data = snapshot.data() ?? <String, dynamic>{};
    final rawItems = (data['items'] as List<dynamic>? ?? <dynamic>[])
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);

    return rawItems.map(CartItemModel.fromJson).toList(growable: false);
  }

  Future<void> saveCart(String uid, List<CartItemModel> items) async {
    await _primaryDoc(uid).set({
      'userId': uid,
      'items': items.map((e) => e.toJson()).toList(growable: false),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
