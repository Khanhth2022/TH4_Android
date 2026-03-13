// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:e_commerce/main.dart';
import 'package:e_commerce/providers/cart_provider.dart';

void main() {
  testWidgets('App renders required home app bar', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(cartProvider: CartProvider()));

    expect(find.text('TH4 - Nhóm [Số nhóm]'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
  });
}
