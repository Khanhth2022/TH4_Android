import 'package:flutter/material.dart';

class ProductImageSlider extends StatefulWidget {
	final List<String> imageUrls;
	final String? heroTag;
	const ProductImageSlider({super.key, required this.imageUrls, this.heroTag});

	@override
	State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
	int _currentIndex = 0;
	late final PageController _controller;

	@override
	void initState() {
		super.initState();
		_controller = PageController();
	}

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		final uniqueImages = widget.imageUrls.toSet().toList();
		List<String> sliderImages;
		if (uniqueImages.length >= 2) {
			sliderImages = uniqueImages;
		} else if (uniqueImages.length == 1) {
			sliderImages = List.filled(3, uniqueImages[0]);
		} else {
			sliderImages = [];
		}
		return Column(
			mainAxisSize: MainAxisSize.min,
			children: [
				SizedBox(
					height: 220,
					child: PageView.builder(
						controller: _controller,
						itemCount: sliderImages.length,
						onPageChanged: (i) => setState(() => _currentIndex = i),
						itemBuilder: (context, index) {
							final imageUrl = sliderImages[index];
							Widget image = Image.network(imageUrl, fit: BoxFit.contain);
							return widget.heroTag != null
									? Hero(tag: '${widget.heroTag!}_$index', child: image)
									: image;
						},
					),
				),
				const SizedBox(height: 8),
				Row(
					mainAxisAlignment: MainAxisAlignment.center,
					children: List.generate(sliderImages.length, (index) {
						return AnimatedContainer(
							duration: const Duration(milliseconds: 200),
							margin: const EdgeInsets.symmetric(horizontal: 4),
							width: _currentIndex == index ? 12 : 8,
							height: 8,
							decoration: BoxDecoration(
								color: _currentIndex == index ? Colors.blueAccent : Colors.grey,
								borderRadius: BorderRadius.circular(4),
							),
						);
					}),
				),
			],
		);
	}
}
