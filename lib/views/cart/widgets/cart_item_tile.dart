import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/cart_model.dart';

class CartItemTile extends StatelessWidget {
	const CartItemTile({
		super.key,
		required this.item,
		required this.onToggle,
		required this.onDecrease,
		required this.onIncrease,
		required this.onRemove,
	});

	final CartItemModel item;
	final ValueChanged<bool?> onToggle;
	final VoidCallback onDecrease;
	final VoidCallback onIncrease;
	final VoidCallback onRemove;

	@override
	Widget build(BuildContext context) {
		return Container(
			decoration: BoxDecoration(
				color: AppColors.surface,
				borderRadius: BorderRadius.circular(14),
				boxShadow: [
					BoxShadow(
						color: Colors.black.withValues(alpha: 0.04),
						blurRadius: 8,
						offset: const Offset(0, 3),
					),
				],
			),
			child: Padding(
				padding: const EdgeInsets.all(10),
				child: Row(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Checkbox(
							value: item.selected,
							onChanged: onToggle,
							activeColor: AppColors.primary,
						),
						ClipRRect(
							borderRadius: BorderRadius.circular(10),
							child: Image.network(
								item.product.image,
								width: 76,
								height: 76,
								fit: BoxFit.cover,
								errorBuilder: (context, error, stackTrace) {
									return Container(
										width: 76,
										height: 76,
										color: Colors.grey.shade200,
										alignment: Alignment.center,
										child: const Icon(Icons.broken_image_outlined),
									);
								},
							),
						),
						const SizedBox(width: 10),
						Expanded(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										item.product.title,
										maxLines: 2,
										overflow: TextOverflow.ellipsis,
										style: const TextStyle(
											color: AppColors.textPrimary,
											fontWeight: FontWeight.w600,
										),
									),
									const SizedBox(height: 4),
									Text(
										'Màu ${item.selectedColor} | Size ${item.selectedSize}',
										style: const TextStyle(
											color: AppColors.textSecondary,
											fontSize: 12,
										),
									),
									const SizedBox(height: 6),
									Text(
										'\$${item.product.price.toStringAsFixed(2)}',
										style: const TextStyle(
											color: AppColors.primary,
											fontWeight: FontWeight.w700,
										),
									),
									const SizedBox(height: 8),
									Row(
										children: [
											_QtyButton(icon: Icons.remove, onTap: onDecrease),
											SizedBox(
												width: 40,
												child: Text(
													'${item.quantity}',
													textAlign: TextAlign.center,
													style: const TextStyle(fontWeight: FontWeight.w600),
												),
											),
											_QtyButton(icon: Icons.add, onTap: onIncrease),
											const Spacer(),
											IconButton(
												onPressed: onRemove,
												tooltip: 'Xóa',
												icon: const Icon(
													Icons.delete_outline,
													color: AppColors.danger,
												),
											),
										],
									),
								],
							),
						),
					],
				),
			),
		);
	}
}

class _QtyButton extends StatelessWidget {
	const _QtyButton({required this.icon, required this.onTap});

	final IconData icon;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: onTap,
			borderRadius: BorderRadius.circular(8),
			child: Ink(
				width: 28,
				height: 28,
				decoration: BoxDecoration(
					borderRadius: BorderRadius.circular(8),
					border: Border.all(color: Colors.grey.shade300),
				),
				child: Icon(icon, size: 18),
			),
		);
	}
}
