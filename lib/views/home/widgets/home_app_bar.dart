import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    super.key,
    required this.cartCount,
    required this.onOrdersPressed,
    required this.onCartPressed,
  });

  final int cartCount;
  final VoidCallback onOrdersPressed;
  final VoidCallback onCartPressed;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: 108,
      toolbarHeight: 62,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFFFF8B2D), AppColors.primary],
            ),
          ),
        ),
      ),
      titleSpacing: 16,
      title: const Text(
        'TH4 - Nhóm 6',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      actions: <Widget>[
        IconButton(
          tooltip: 'Đơn mua',
          onPressed: onOrdersPressed,
          icon: const Icon(Icons.receipt_long_outlined),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              IconButton(
                tooltip: 'Giỏ hàng',
                onPressed: onCartPressed,
                icon: const Icon(Icons.shopping_bag_outlined),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 2,
                  top: 6,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cartCount > 99 ? '99+' : '$cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class SearchBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  SearchBarHeaderDelegate({
    required this.controller,
    required this.onChanged,
    this.hintText = 'Tìm sản phẩm, danh mục...',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  double get minExtent => 70;

  @override
  double get maxExtent => 70;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = overlapsContent ? 1.0 : 0.0;
    final bgColor = Color.lerp(
      Colors.transparent,
      AppColors.primary,
      progress,
    )!;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Material(
        elevation: overlapsContent ? 2 : 0,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                    icon: const Icon(Icons.clear),
                  ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SearchBarHeaderDelegate oldDelegate) {
    return oldDelegate.controller != controller ||
        oldDelegate.hintText != hintText ||
        oldDelegate.onChanged != onChanged;
  }
}
