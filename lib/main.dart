import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'providers/cart_provider.dart';
import 'views/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cartProvider = CartProvider();
  await cartProvider.loadCart();

  runApp(MyApp(cartProvider: cartProvider));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.cartProvider});

  final CartProvider cartProvider;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CartProvider>.value(
      value: cartProvider,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'E-Commerce TH4',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.accent,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
