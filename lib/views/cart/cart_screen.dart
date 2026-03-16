import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../checkout/checkout_screen.dart';
import '../checkout/order_history_screen.dart';
import 'widgets/cart_item_tile.dart';
import 'widgets/cart_summary_bar.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Giỏ hàng'),
				actions: [
					IconButton(
						tooltip: 'Đơn mua',
						onPressed: () {
							Navigator.of(context).push(
								MaterialPageRoute<void>(
									builder: (_) => const OrderHistoryScreen(),
								),
							);
						},
						icon: const Icon(Icons.receipt_long_outlined),
					),
					Consumer<CartProvider>(
						builder: (context, cart, child) {
							return IconButton(
								tooltip: 'Xóa sản phẩm đã chọn',
								onPressed: cart.selectedItems.isEmpty
										? null
										: () => _confirmClearSelected(context),
								icon: const Icon(Icons.delete_sweep_outlined),
							);
						},
					),
				],
			),
			body: Consumer<CartProvider>(
				builder: (context, cart, child) {
					if (cart.items.isEmpty) {
						return _EmptyCartView(
							onGoShopping: () => Navigator.of(context).pop(),
						);
					}

					return Column(
						children: [
							Expanded(
								child: ListView.separated(
									padding: const EdgeInsets.all(12),
									itemCount: cart.items.length,
									separatorBuilder: (context, index) =>
											const SizedBox(height: 10),
									itemBuilder: (context, index) {
										final item = cart.items[index];
										return CartItemTile(
											item: item,
											onToggle: (value) {
												cart.toggleItemSelection(index, value);
											},
											onDecrease: () => cart.decreaseQty(index),
											onIncrease: () => cart.increaseQty(index),
											onRemove: () => _confirmRemoveItem(context, index),
										);
									},
								),
							),
							CartSummaryBar(
								isSelectAll: cart.isSelectAll,
								selectedCount: cart.selectedItems.length,
								total: cart.selectedTotalPrice,
								onToggleSelectAll: (selected) {
									cart.toggleSelectAll(selected);
								},
								onBuy: () => _goToCheckout(context),
							),
						],
					);
				},
			),
		);
	}

  Future<void> _confirmRemoveItem(BuildContext context, int index) async {
    final cart = context.read<CartProvider>();
    final productName = cart.items[index].product.title;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa sản phẩm'),
          content: Text('Bạn có muốn xóa "$productName" khỏi giỏ hàng?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirm == true && context.mounted) {
      await cart.removeAt(index);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã xóa sản phẩm')));
      }
    }
  }

  Future<void> _confirmClearSelected(BuildContext context) async {
    final cart = context.read<CartProvider>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa các sản phẩm đã chọn'),
          content: const Text(
            'Bạn có chắc muốn xóa tất cả sản phẩm đang chọn?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirm == true && context.mounted) {
      final removedCount = cart.selectedItems.length;
      await cart.clearSelected();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa $removedCount sản phẩm đã chọn')),
        );
      }
    }
  }

	Future<void> _goToCheckout(BuildContext context) async {
		final cart = context.read<CartProvider>();
		if (cart.selectedItems.isEmpty) {
			return;
		}

		final checkoutItems = cart.selectedItems
				.map(
					(item) => item.copyWith(
						product: item.product,
						quantity: item.quantity,
						selected: item.selected,
						selectedSize: item.selectedSize,
						selectedColor: item.selectedColor,
					),
				)
				.toList(growable: false);

		await Navigator.of(context).push(
			MaterialPageRoute<void>(
				builder: (_) => CheckoutScreen(items: checkoutItems),
			),
		);
	}
}

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView({required this.onGoShopping});

  final VoidCallback onGoShopping;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 72,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Giỏ hàng của bạn đang trống',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Thêm sản phẩm để bắt đầu mua sắm.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onGoShopping,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Mua ngay'),
            ),
          ],
        ),
      ),
    );
  }
}
