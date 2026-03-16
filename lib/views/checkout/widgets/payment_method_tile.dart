import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/order_model.dart';

class PaymentMethodTile extends StatelessWidget {
	const PaymentMethodTile({
		super.key,
		required this.icon,
		required this.title,
		required this.subtitle,
		required this.value,
		required this.groupValue,
		required this.onChanged,
	});

	final IconData icon;
	final String title;
	final String subtitle;
	final PaymentMethod value;
	final PaymentMethod groupValue;
	final ValueChanged<PaymentMethod> onChanged;

	@override
	Widget build(BuildContext context) {
		final selected = value == groupValue;

		return InkWell(
			borderRadius: BorderRadius.circular(12),
			onTap: () => onChanged(value),
			child: Container(
				padding: const EdgeInsets.all(12),
				decoration: BoxDecoration(
					color: selected ? const Color(0xFFFFF5EC) : Colors.white,
					borderRadius: BorderRadius.circular(12),
					border: Border.all(
						color: selected ? AppColors.primary : const Color(0xFFE5E7EB),
					),
				),
				child: Row(
					children: <Widget>[
						Container(
							width: 40,
							height: 40,
							decoration: BoxDecoration(
								color: selected ? AppColors.primary : const Color(0xFFF3F4F6),
								borderRadius: BorderRadius.circular(10),
							),
							alignment: Alignment.center,
							child: Icon(
								icon,
								color: selected ? Colors.white : AppColors.textSecondary,
							),
						),
						const SizedBox(width: 12),
						Expanded(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: <Widget>[
									Text(
										title,
										style: const TextStyle(
											fontWeight: FontWeight.w700,
											color: AppColors.textPrimary,
										),
									),
									const SizedBox(height: 2),
									Text(
										subtitle,
										style: const TextStyle(
											color: AppColors.textSecondary,
											fontSize: 12,
										),
									),
								],
							),
						),
						Radio<PaymentMethod>(
							value: value,
							groupValue: groupValue,
							onChanged: (newValue) {
								if (newValue != null) {
									onChanged(newValue);
								}
							},
							activeColor: AppColors.primary,
						),
					],
				),
			),
		);
	}
}
