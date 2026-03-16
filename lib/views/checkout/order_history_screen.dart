import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'order_local_store.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Future<List<CheckoutOrder>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = OrderLocalStore.getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đơn mua'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Chờ xác nhận'),
              Tab(text: 'Đang giao'),
              Tab(text: 'Đã giao'),
              Tab(text: 'Đã hủy'),
            ],
          ),
        ),
        body: FutureBuilder<List<CheckoutOrder>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final allOrders = snapshot.data ?? <CheckoutOrder>[];

            return TabBarView(
              children: [
                _OrderTabBody(
                  orders: _filterByStatus(
                    allOrders,
                    CheckoutOrderStatus.pending,
                  ),
                ),
                _OrderTabBody(
                  orders: _filterByStatus(
                    allOrders,
                    CheckoutOrderStatus.shipping,
                  ),
                ),
                _OrderTabBody(
                  orders: _filterByStatus(
                    allOrders,
                    CheckoutOrderStatus.delivered,
                  ),
                ),
                _OrderTabBody(
                  orders: _filterByStatus(
                    allOrders,
                    CheckoutOrderStatus.canceled,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<CheckoutOrder> _filterByStatus(
    List<CheckoutOrder> allOrders,
    String status,
  ) {
    return allOrders.where((order) => order.status == status).toList();
  }
}

class _OrderTabBody extends StatelessWidget {
  const _OrderTabBody({required this.orders});

  final List<CheckoutOrder> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có đơn hàng trong mục này.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _OrderCard(order: order);
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final CheckoutOrder order;

  @override
  Widget build(BuildContext context) {
    final dateText = _formatDate(order.createdAt);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mã đơn: ${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                CheckoutOrderStatus.toDisplayName(order.status),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            dateText,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Địa chỉ: ${order.address}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'Thanh toán: ${CheckoutPaymentMethod.toDisplayName(order.paymentMethod)}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const Divider(height: 20),
          Text(
            '${order.items.length} sản phẩm',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Tổng tiền: \$${order.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}
