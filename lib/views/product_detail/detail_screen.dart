import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../auth/auth_gate.dart';
import '../cart/cart_screen.dart';
import 'widgets/expandable_text.dart';
import 'widgets/product_image_slider.dart';
import 'widgets/variation_picker.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.product,
    this.heroTag,
    this.imageUrls,
  });

  final ProductModel product;
  final String? heroTag;
  final List<String>? imageUrls;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String selectedSize = 'M';
  String selectedColor = 'Ð?';
  int quantity = 1;
  final List<String> sizes = ['S', 'M', 'L'];
  final List<String> colors = ['Ð?', 'Xanh'];

  void _goToCart() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
  }

  Future<void> _openChatInput() async {
    final messenger = ScaffoldMessenger.of(context);
    String messageText = '';

    final String? submittedMessage = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nh?n tin v?i shop',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              TextField(
                autofocus: true,
                maxLines: 3,
                minLines: 1,
                onChanged: (value) => messageText = value,
                decoration: const InputDecoration(
                  hintText: 'Nh?p tin nh?n cho shop...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    FocusScope.of(sheetContext).unfocus();
                    Navigator.pop(sheetContext, messageText.trim());
                  },
                  child: const Text('G?i tin nh?n'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || submittedMessage == null) {
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          submittedMessage.isEmpty
              ? 'Vui lòng nh?p n?i dung tin nh?n'
              : 'Ðã g?i tin nh?n t?i shop',
        ),
      ),
    );
  }

  Future<void> _showAddToCartSheet() async {
    final canContinue = await ensureAuthenticated(context);
    if (!canContinue || !mounted) {
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        String tempSize = selectedSize;
        String tempColor = selectedColor;
        int tempQuantity = quantity;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Image.network(
                          widget.product.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatPrice(widget.product.price),
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  VariationPicker(
                    sizes: sizes,
                    colors: colors,
                    selectedSize: tempSize,
                    selectedColor: tempColor,
                    onSizeChanged: (v) => setModalState(() => tempSize = v),
                    onColorChanged: (v) => setModalState(() => tempColor = v),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Text('S? lu?ng:'),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: tempQuantity > 1
                            ? () => setModalState(() => tempQuantity--)
                            : null,
                      ),
                      Text(
                        '$tempQuantity',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setModalState(() => tempQuantity++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedSize = tempSize;
                          selectedColor = tempColor;
                          quantity = tempQuantity;
                        });
                        Provider.of<CartProvider>(
                          context,
                          listen: false,
                        ).addToCart(
                          widget.product,
                          quantity: quantity,
                          size: selectedSize,
                          color: selectedColor,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Thêm vào gi? hàng thành công'),
                          ),
                        );
                      },
                      child: const Text('Xác nh?n'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
        );
      },
    );
  }

  String _formatPrice(double value) {
    final rounded = (value * 24000).round();
    final raw = rounded.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final position = raw.length - i;
      buffer.write(raw[i]);
      if (position > 1 && position % 3 == 1) {
        buffer.write('.');
      }
    }
    return '${buffer.toString()}d';
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final double originalPrice = (product.price * 1.2).roundToDouble();
    final List<String> images = widget.imageUrls ?? product.images;
    const addToCartColor = Color(0xFFFF8F00);
    const buyNowColor = Color(0xFFC62828);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi ti?t s?n ph?m'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductImageSlider(
                imageUrls: images,
                heroTag: widget.heroTag ?? 'product_${product.id}',
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: widget.heroTag ?? 'product_${product.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          product.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          _formatPrice(product.price),
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatPrice(originalPrice),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: _showAddToCartSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.tune,
                              size: 20,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Ch?n Kích c?, Màu s?c',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '$selectedSize, $selectedColor',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Mô t? s?n ph?m:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    ExpandableText(text: product.description),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: _openChatInput,
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: _goToCart,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showAddToCartSheet(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: addToCartColor,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFE07B00), width: 1),
                ),
                child: const Text('Thêm vào gi? hàng'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  final canContinue = await ensureAuthenticated(context);
                  if (!canContinue || !context.mounted) {
                    return;
                  }

                  Provider.of<CartProvider>(context, listen: false).addToCart(
                    product,
                    quantity: quantity,
                    size: selectedSize,
                    color: selectedColor,
                  );
                  _goToCart();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buyNowColor,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFB71C1C), width: 1),
                ),
                child: const Text('Mua ngay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
