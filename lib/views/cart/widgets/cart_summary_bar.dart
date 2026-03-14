import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class CartSummaryBar extends StatelessWidget {
	const CartSummaryBar({
		super.key,
		required this.isSelectAll,
		required this.selectedCount,
		required this.total,
		required this.onToggleSelectAll,
		required this.onBuy,
	});

	final bool isSelectAll;
	final int selectedCount;
	final double total;
	final ValueChanged<bool> onToggleSelectAll;
	final VoidCallback onBuy;

	@override
	Widget build(BuildContext context) {
		final canBuy = selectedCount > 0;

		return Container(
			padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
			decoration: BoxDecoration(
				color: Colors.white,
				border: Border(top: BorderSide(color: Colors.grey.shade200)),
			),
			child: SafeArea(
				top: false,
				child: Row(
					children: [
						Row(
							children: [
								Checkbox(
									value: isSelectAll,
									onChanged: (value) => onToggleSelectAll(value ?? false),
									activeColor: AppColors.primary,
								),
								const Text('Tất cả'),
							],
						),
						const SizedBox(width: 8),
						Expanded(
							child: Column(
								mainAxisSize: MainAxisSize.min,
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									const Text(
										'Tổng tiền',
										style: TextStyle(
											color: AppColors.textSecondary,
											fontSize: 12,
										),
									),
									Text(
										'\$${total.toStringAsFixed(2)}',
										style: const TextStyle(
											color: AppColors.primary,
											fontWeight: FontWeight.w700,
											fontSize: 18,
										),
									),
								],
							),
						),
						const SizedBox(width: 8),
						ElevatedButton(
							onPressed: canBuy ? onBuy : null,
							style: ElevatedButton.styleFrom(
								backgroundColor: AppColors.primary,
								foregroundColor: Colors.white,
								padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(12),
								),
							),
							child: Text('Mua ($selectedCount)'),
						),
					],
				),
			),
		);
	}
}
