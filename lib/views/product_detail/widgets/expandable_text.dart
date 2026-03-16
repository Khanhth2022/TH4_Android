import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
	final String text;
	const ExpandableText({Key? key, required this.text}) : super(key: key);

	@override
	State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
	bool expanded = false;
	static const int maxLines = 5;

	@override
	Widget build(BuildContext context) {
		final textWidget = Text(
			widget.text,
			maxLines: expanded ? null : maxLines,
			overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
		);
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				textWidget,
				if (_isLongText(widget.text))
					TextButton(
						onPressed: () => setState(() => expanded = !expanded),
						child: Text(expanded ? 'Thu gọn' : 'Xem thêm'),
					),
			],
		);
	}

	bool _isLongText(String text) {
		// Đơn giản: nếu text có nhiều hơn 200 ký tự thì coi là dài
		return text.length > 200;
	}
}
