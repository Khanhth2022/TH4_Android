import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class AddressSection extends StatelessWidget {
	const AddressSection({
		super.key,
		required this.controller,
	});

	final TextEditingController controller;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.all(12),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(12),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					const Text(
						'Địa chỉ nhận hàng',
						style: TextStyle(
							fontSize: 16,
							fontWeight: FontWeight.w700,
							color: AppColors.textPrimary,
						),
					),
					const SizedBox(height: 10),
					TextField(
						controller: controller,
						maxLines: 3,
						minLines: 2,
						textInputAction: TextInputAction.done,
						decoration: InputDecoration(
							hintText: 'Ví dụ: 123 Nguyễn Huệ, Quận 1, TP.HCM',
							filled: true,
							fillColor: const Color(0xFFF8FAFC),
							border: OutlineInputBorder(
								borderRadius: BorderRadius.circular(12),
								borderSide: BorderSide.none,
							),
							focusedBorder: OutlineInputBorder(
								borderRadius: BorderRadius.circular(12),
								borderSide: const BorderSide(color: AppColors.primary),
							),
						),
					),
				],
			),
		);
	}
}
