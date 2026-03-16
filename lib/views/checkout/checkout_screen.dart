import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/cart_model.dart';
import '../../providers/cart_provider.dart';
import 'order_history_screen.dart';
import 'order_local_store.dart';
import 'widgets/address_section.dart';
import 'widgets/payment_method_tile.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.selectedItems});

  final List<CartItemModel> selectedItems;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _addressController = TextEditingController();
  String _paymentMethod = CheckoutPaymentMethod.cod;
  bool _isPlacingOrder = false;

  double get _total {
    return widget.selectedItems.fold<double>(
      0,
      (sum, item) => sum + item.subtotal,
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ nhận hàng.')),
      );
      return;
    }

    if (_isPlacingOrder) {
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final order = CheckoutOrder(
        id: 'OD${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        address: address,
        paymentMethod: _paymentMethod,
        status: CheckoutOrderStatus.pending,
        items: widget.selectedItems.map((item) => item.copyWith()).toList(),
        totalAmount: _total,
      );

      await OrderLocalStore.addOrder(order);
      await context.read<CartProvider>().clearSelected();

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Đặt hàng thành công'),
            content: const Text('Đơn hàng của bạn đã được ghi nhận.'),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Về trang chủ'),
              ),
            ],
          );
        },
      );

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
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
        ],
      ),
      body: widget.selectedItems.isEmpty
          ? const _EmptyCheckoutView()
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        _SectionCard(
                          title:
                              'Sản phẩm đã chọn (${widget.selectedItems.length})',
                          child: Column(
                            children: [
                              for (final item in widget.selectedItems)
                                _CheckoutItemTile(item: item),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        AddressSection(controller: _addressController),
                        const SizedBox(height: 12),
                        _SectionCard(
                          title: 'Phương thức thanh toán',
                          child: Column(
                            children: [
                              PaymentMethodTile(
                                title: 'Thanh toán khi nhận hàng (COD)',
                                subtitle: 'Thanh toán tiền mặt cho shipper',
                                value: CheckoutPaymentMethod.cod,
                                groupValue: _paymentMethod,
                                icon: Icons.local_shipping_outlined,
                                onChanged: (value) {
                                  setState(() {
                                    _paymentMethod = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                              PaymentMethodTile(
                                title: 'Ví điện tử Momo',
                                subtitle: 'Mô phỏng thanh toán qua Momo',
                                value: CheckoutPaymentMethod.momo,
                                groupValue: _paymentMethod,
                                icon: Icons.account_balance_wallet_outlined,
                                onChanged: (value) {
                                  setState(() {
                                    _paymentMethod = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tổng thanh toán',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '\$${_total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: _isPlacingOrder ? null : _placeOrder,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                            ),
                            child: Text(
                              _isPlacingOrder ? 'Đang xử lý...' : 'Đặt Hàng',
                            ),
                          ),
                        ],
                      ),
                    ),
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          item.product.image,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 52,
            height: 52,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const Icon(Icons.image_not_supported_outlined),
          ),
        ),
      ),
      title: Text(
        item.product.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        'SL: ${item.quantity} | ${item.selectedSize} | ${item.selectedColor}',
      ),
      trailing: Text(
        '\$${item.subtotal.toStringAsFixed(2)}',
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          child,
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
      child: Text(
        'Không có sản phẩm nào để thanh toán.',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
