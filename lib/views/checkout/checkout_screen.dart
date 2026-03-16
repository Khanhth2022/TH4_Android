import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/cart_model.dart';
import '../../models/order_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import 'order_history_screen.dart';
import 'widgets/address_section.dart';
import 'widgets/payment_method_tile.dart';

class CheckoutScreen extends StatefulWidget {
	const CheckoutScreen({super.key, required this.items});

	final List<CartItemModel> items;

	@override
	State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
	final TextEditingController _addressController = TextEditingController();
	PaymentMethod _paymentMethod = PaymentMethod.cod;
	bool _isSubmitting = false;

	double get _total => widget.items.fold(
				0,
				(sum, item) => sum + item.subtotal,
			);

	@override
	void dispose() {
		_addressController.dispose();
		super.dispose();
	}

	Future<void> _placeOrder() async {
		if (_isSubmitting || widget.items.isEmpty) {
			return;
		}

		final address = _addressController.text.trim();
		if (address.isEmpty) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('Vui lòng nhập địa chỉ nhận hàng.')),
			);
			return;
		}

		setState(() {
			_isSubmitting = true;
		});

		try {
			final orderProvider = context.read<OrderProvider>();
			final cartProvider = context.read<CartProvider>();

			final order = await orderProvider.placeOrder(
				items: widget.items,
				address: address,
				paymentMethod: _paymentMethod,
			);
			await cartProvider.removeItems(widget.items);

			if (!mounted) {
				return;
			}

			await showDialog<void>(
				context: context,
				builder: (dialogContext) {
					return AlertDialog(
						title: const Text('Đặt hàng thành công'),
						content: Text(
							'Mã đơn: ${order.id}\n'
							'Thanh toán: ${order.paymentMethod.label}\n'
							'Tổng tiền: \$${order.totalAmount.toStringAsFixed(2)}',
						),
						actions: <Widget>[
							FilledButton(
								onPressed: () => Navigator.of(dialogContext).pop(),
								child: const Text('Về Trang chủ'),
							),
						],
					);
				},
			);

			if (!mounted) {
				return;
			}

			Navigator.of(context).popUntil((route) => route.isFirst);
		} catch (_) {
			if (!mounted) {
				return;
			}
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('Có lỗi xảy ra khi đặt hàng.')),
			);
		} finally {
			if (mounted) {
				setState(() {
					_isSubmitting = false;
				});
			}
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Thanh toán'),
				actions: <Widget>[
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
				],
			),
			body: widget.items.isEmpty
					? const _EmptyCheckoutView()
					: Column(
							children: <Widget>[
								Expanded(
									child: SingleChildScrollView(
										padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: <Widget>[
												const Text(
													'Sản phẩm đã chọn',
													style: TextStyle(
														fontSize: 16,
														fontWeight: FontWeight.w700,
														color: AppColors.textPrimary,
													),
												),
												const SizedBox(height: 8),
												...widget.items.map(
													(item) => Padding(
														padding: const EdgeInsets.only(bottom: 8),
														child: _CheckoutItemTile(item: item),
													),
												),
												const SizedBox(height: 8),
												AddressSection(controller: _addressController),
												const SizedBox(height: 12),
												const Text(
													'Phương thức thanh toán',
													style: TextStyle(
														fontSize: 16,
														fontWeight: FontWeight.w700,
														color: AppColors.textPrimary,
													),
												),
												const SizedBox(height: 8),
												PaymentMethodTile(
													icon: Icons.local_shipping_outlined,
													title: 'COD',
													subtitle: 'Thanh toán khi nhận hàng',
													value: PaymentMethod.cod,
													groupValue: _paymentMethod,
													onChanged: (value) {
														setState(() {
															_paymentMethod = value;
														});
													},
												),
												const SizedBox(height: 8),
												PaymentMethodTile(
													icon: Icons.account_balance_wallet_outlined,
													title: 'Momo',
													subtitle: 'Ví điện tử Momo',
													value: PaymentMethod.momo,
													groupValue: _paymentMethod,
													onChanged: (value) {
														setState(() {
															_paymentMethod = value;
														});
													},
												),
											],
										),
									),
								),
								_CheckoutBottomBar(
									total: _total,
									isSubmitting: _isSubmitting,
									onPlaceOrder: _placeOrder,
								),
							],
						),
		);
	}
}

class _CheckoutBottomBar extends StatelessWidget {
	const _CheckoutBottomBar({
		required this.total,
		required this.isSubmitting,
		required this.onPlaceOrder,
	});

	final double total;
	final bool isSubmitting;
	final VoidCallback onPlaceOrder;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
			decoration: BoxDecoration(
				color: Colors.white,
				border: Border(top: BorderSide(color: Colors.grey.shade200)),
			),
			child: SafeArea(
				top: false,
				child: Row(
					children: <Widget>[
						Expanded(
							child: Column(
								mainAxisSize: MainAxisSize.min,
								crossAxisAlignment: CrossAxisAlignment.start,
								children: <Widget>[
									const Text(
										'Tổng thanh toán',
										style: TextStyle(
											fontSize: 12,
											color: AppColors.textSecondary,
										),
									),
									Text(
										'\$${total.toStringAsFixed(2)}',
										style: const TextStyle(
											color: AppColors.primary,
											fontSize: 20,
											fontWeight: FontWeight.w800,
										),
									),
								],
							),
						),
						const SizedBox(width: 12),
						ElevatedButton(
							onPressed: isSubmitting ? null : onPlaceOrder,
							style: ElevatedButton.styleFrom(
								backgroundColor: AppColors.primary,
								foregroundColor: Colors.white,
								padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(12),
								),
							),
							child: isSubmitting
									? const SizedBox(
											width: 18,
											height: 18,
											child: CircularProgressIndicator(
												strokeWidth: 2,
												color: Colors.white,
											),
										)
									: const Text('Đặt Hàng'),
						),
					],
				),
			),
		);
	}
}

class _CheckoutItemTile extends StatelessWidget {
	const _CheckoutItemTile({required this.item});

	final CartItemModel item;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.all(10),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(12),
			),
			child: Row(
				children: <Widget>[
					ClipRRect(
						borderRadius: BorderRadius.circular(10),
						child: Image.network(
							item.product.image,
							width: 64,
							height: 64,
							fit: BoxFit.cover,
							errorBuilder: (_, __, ___) {
								return Container(
									width: 64,
									height: 64,
									color: const Color(0xFFF3F4F6),
									alignment: Alignment.center,
									child: const Icon(Icons.image_not_supported_outlined),
								);
							},
						),
					),
					const SizedBox(width: 10),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: <Widget>[
								Text(
									item.product.title,
									maxLines: 2,
									overflow: TextOverflow.ellipsis,
									style: const TextStyle(
										fontWeight: FontWeight.w700,
										color: AppColors.textPrimary,
									),
								),
								const SizedBox(height: 4),
								Text(
									'SL: ${item.quantity} | Size: ${item.selectedSize} | Màu: ${item.selectedColor}',
									style: const TextStyle(
										color: AppColors.textSecondary,
										fontSize: 12,
									),
								),
								const SizedBox(height: 6),
								Text(
									'\$${item.subtotal.toStringAsFixed(2)}',
									style: const TextStyle(
										color: AppColors.primary,
										fontWeight: FontWeight.w700,
									),
								),
							],
						),
					),
				],
			),
		);
	}
}

class _EmptyCheckoutView extends StatelessWidget {
	const _EmptyCheckoutView();

	@override
	Widget build(BuildContext context) {
		return const Center(
			child: Padding(
				padding: EdgeInsets.all(24),
				child: Text(
					'Không có sản phẩm nào để thanh toán.',
					textAlign: TextAlign.center,
					style: TextStyle(
						color: AppColors.textSecondary,
						fontSize: 16,
					),
				),
			),
		);
	}
}
