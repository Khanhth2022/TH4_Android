import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'auth_screen.dart';

Future<bool> ensureAuthenticated(BuildContext context) async {
  final auth = context.read<AuthProvider>();
  if (auth.isAuthenticated) {
    return true;
  }

  final shouldOpenLogin = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Yêu cầu đăng nhập'),
        content: const Text(
          'Bạn cần đăng nhập hoặc đăng ký để thực hiện thao tác này.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Để sau'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Đăng nhập ngay'),
          ),
        ],
      );
    },
  );

  if (shouldOpenLogin != true || !context.mounted) {
    return false;
  }

  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(builder: (_) => const AuthScreen()),
  );

  if (result == true && context.mounted) {
    return context.read<AuthProvider>().isAuthenticated;
  }

  return false;
}
