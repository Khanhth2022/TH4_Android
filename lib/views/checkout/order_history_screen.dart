import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class OrderHistoryScreen extends StatelessWidget {
	const OrderHistoryScreen({super.key});

	static const List<OrderStatus> _statuses = <OrderStatus>[
		OrderStatus.pending,
		OrderStatus.shipping,
		OrderStatus.delivered,
		OrderStatus.cancelled,
	];

	@override
	Widget build(BuildContext context) {
		return DefaultTabController(
			length: _statuses.length,
			child: Scaffold(
				appBar: AppBar(
					title: const Text('Đơn mua'),
				),
				body: Column(
					children: <Widget>[
						Material(
							color: Colors.white,
							child: TabBar(
								isScrollable: true,
								indicatorColor: AppColors.primary,
								labelColor: AppColors.primary,
								unselectedLabelColor: AppColors.textSecondary,
								tabs: _statuses
										.map((status) => Tab(text: status.label))
										.toList(growable: false),
							),
						),
						Expanded(
							child: Consumer<OrderProvider>(
								builder: (context, orderProvider, _) {
									return TabBarView(
										children: _statuses
												.map(
													(status) => _OrdersTabContent(
														orders: orderProvider.ordersByStatus(status),
														emptyMessage:
																'Chưa có đơn nào ở trạng thái "${status.label}".',
													),
												)
												.toList(growable: false),
									);
								},
							),
						),
					],
				),
			),
		);
	}
}

class _OrdersTabContent extends StatelessWidget {
	const _OrdersTabContent({
		required this.orders,
		required this.emptyMessage,
	});

	final List<OrderModel> orders;
	final String emptyMessage;

	@override
	Widget build(BuildContext context) {
		if (orders.isEmpty) {
			return Center(
				child: Padding(
					padding: const EdgeInsets.all(20),
					child: Text(
						emptyMessage,
						textAlign: TextAlign.center,
						style: const TextStyle(color: AppColors.textSecondary),
					),
				),
			);
		}

		return ListView.separated(
			padding: const EdgeInsets.all(12),
			itemCount: orders.length,
			separatorBuilder: (_, __) => const SizedBox(height: 10),
			itemBuilder: (context, index) => _OrderCard(order: orders[index]),
		);
	}
}

class _OrderCard extends StatelessWidget {
	const _OrderCard({required this.order});

	final OrderModel order;

	String _formatDate(DateTime value) {
		String twoDigits(int number) => number.toString().padLeft(2, '0');

		return '${twoDigits(value.day)}/${twoDigits(value.month)}/${value.year} '
				'${twoDigits(value.hour)}:${twoDigits(value.minute)}';
	}

	@override
	Widget build(BuildContext context) {
		final statusColor = switch (order.status) {
			OrderStatus.pending => const Color(0xFFF59E0B),
			OrderStatus.shipping => const Color(0xFF2563EB),
			OrderStatus.delivered => const Color(0xFF16A34A),
			OrderStatus.cancelled => const Color(0xFFDC2626),
		};

		return Container(
			padding: const EdgeInsets.all(12),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(12),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					Row(
						children: <Widget>[
							Expanded(
								child: Text(
									'Mã đơn: ${order.id}',
									style: const TextStyle(
										fontWeight: FontWeight.w700,
										color: AppColors.textPrimary,
									),
								),
							),
							Container(
								padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
								decoration: BoxDecoration(
									color: statusColor.withValues(alpha: 0.12),
									borderRadius: BorderRadius.circular(20),
								),
								child: Text(
									order.status.label,
									style: TextStyle(
										color: statusColor,
										fontSize: 12,
										fontWeight: FontWeight.w700,
									),
								),
							),
						],
					),
					const SizedBox(height: 6),
					Text(
						_formatDate(order.createdAt),
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
					const SizedBox(height: 2),
					Text(
						'Thanh toán: ${order.paymentMethod.label}',
						style: const TextStyle(color: AppColors.textSecondary),
					),
					const SizedBox(height: 8),
					...order.items.map(
						(item) => Padding(
							padding: const EdgeInsets.only(bottom: 4),
							child: Row(
								children: <Widget>[
									Expanded(
										child: Text(
											'${item.product.title} x${item.quantity}',
											maxLines: 1,
											overflow: TextOverflow.ellipsis,
										),
									),
									Text('\$${item.subtotal.toStringAsFixed(2)}'),
								],
							),
						),
					),
					const Divider(height: 16),
					Row(
						children: <Widget>[
							Text(
								'${order.totalUnits} sản phẩm',
								style: const TextStyle(color: AppColors.textSecondary),
							),
							const Spacer(),
							Text(
								'Tổng: \$${order.totalAmount.toStringAsFixed(2)}',
								style: const TextStyle(
									color: AppColors.primary,
									fontWeight: FontWeight.w700,
								),
							),
						],
					),
				],
			),
		);
	}
}
