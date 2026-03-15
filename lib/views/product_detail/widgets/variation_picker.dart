import 'package:flutter/material.dart';

class VariationPicker extends StatelessWidget {
	final List<String> sizes;
	final List<String> colors;
	final String selectedSize;
	final String selectedColor;
	final ValueChanged<String> onSizeChanged;
	final ValueChanged<String> onColorChanged;
	const VariationPicker({
		Key? key,
		required this.sizes,
		required this.colors,
		required this.selectedSize,
		required this.selectedColor,
		required this.onSizeChanged,
		required this.onColorChanged,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				const Text('Chọn size:'),
				Wrap(
					spacing: 8,
					children: sizes.map((size) => ChoiceChip(
						label: Text(size),
						selected: selectedSize == size,
						onSelected: (_) => onSizeChanged(size),
					)).toList(),
				),
				const SizedBox(height: 12),
				const Text('Chọn màu:'),
				Wrap(
					spacing: 8,
					children: colors.map((color) => ChoiceChip(
						label: Text(color),
						selected: selectedColor == color,
						onSelected: (_) => onColorChanged(color),
					)).toList(),
				),
			],
		);
	}
}
