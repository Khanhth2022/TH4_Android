// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:e_commerce/views/home/widgets/home_app_bar.dart';

void main() {
  testWidgets('App renders required home app bar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CustomScrollView(
          slivers: <Widget>[
            HomeAppBar(
              cartCount: 0,
              isAuthenticated: false,
              onAuthPressed: _noop,
              onOrdersPressed: _noop,
              onCartPressed: _noop,
            ),
          ],
        ),
      ),
    );

    expect(find.text('TH4 - Nhóm 6'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
  });
}

void _noop() {}
