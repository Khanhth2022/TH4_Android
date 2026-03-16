import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../product_detail/detail_screen.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../cart/cart_screen.dart';
import '../checkout/order_history_screen.dart';
import 'widgets/banner_slider.dart';
import 'widgets/category_item.dart';
import 'widgets/home_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProductProvider>(
      create: (_) => ProductProvider()..fetchInitialProducts(),
      child: const _HomeScreenBody(),
    );
  }
}

class _HomeScreenBody extends StatefulWidget {
  const _HomeScreenBody();

  @override
  State<_HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<_HomeScreenBody> {
  static const List<String> _bannerUrls = <String>[
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=1200&q=80',
  ];

  static const List<_HomeCategory> _homeCategories = <_HomeCategory>[
    _HomeCategory(
      label: 'Thời trang',
      icon: Icons.checkroom_outlined,
      searchKeyword: 'clothing',
    ),
    _HomeCategory(
      label: 'Điện thoại',
      icon: Icons.phone_iphone_outlined,
      searchKeyword: 'phone',
    ),
    _HomeCategory(
      label: 'Laptop',
      icon: Icons.laptop_mac_outlined,
      searchKeyword: 'laptop',
    ),
    _HomeCategory(
      label: 'Mỹ phẩm',
      icon: Icons.face_retouching_natural_outlined,
      searchKeyword: 'beauty',
    ),
    _HomeCategory(
      label: 'Đồng hồ',
      icon: Icons.watch_outlined,
      searchKeyword: 'watch',
    ),
    _HomeCategory(
      label: 'Phụ kiện',
      icon: Icons.headphones_outlined,
      providerCategory: 'electronics',
    ),
  ];

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryLabel;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final provider = context.read<ProductProvider>();
    if (_scrollController.position.extentAfter < 480) {
      provider.loadMoreProducts();
    }
  }

  Future<void> _onRefresh() {
    return context.read<ProductProvider>().refreshProducts();
  }

  bool _isCategorySelected(_HomeCategory category) {
    return _selectedCategoryLabel == category.label;
  }

  void _clearCategoryFilter(ProductProvider provider) {
    setState(() {
      _selectedCategoryLabel = null;
    });

    _searchController.clear();
    provider.selectCategory(ProductProvider.allCategory);
    provider.updateSearchQuery('');
  }

  void _applyCategoryFilter(ProductProvider provider, _HomeCategory category) {
    setState(() {
      _selectedCategoryLabel = category.label;
    });

    if (category.providerCategory != null) {
      _searchController.clear();
      provider.selectCategory(category.providerCategory!);
      provider.updateSearchQuery('');
      return;
    }

    final keyword = category.searchKeyword ?? '';
    _searchController.value = TextEditingValue(
      text: keyword,
      selection: TextSelection.collapsed(offset: keyword.length),
    );
    provider.selectCategory(ProductProvider.allCategory);
    provider.updateSearchQuery(keyword);
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.select<CartProvider, int>(
      (cart) => cart.itemTypesCount,
    );

    return Scaffold(
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          final products = productProvider.filteredProducts;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _onRefresh,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                HomeAppBar(
                  cartCount: cartCount,
                  onOrdersPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const OrderHistoryScreen(),
                      ),
                    );
                  },
                  onCartPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const CartScreen(),
                      ),
                    );
                  },
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: SearchBarHeaderDelegate(
                    controller: _searchController,
                    onChanged: productProvider.updateSearchQuery,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: BannerSlider(imageUrls: _bannerUrls),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                    child: _SectionHeader(
                      title: 'Danh mục sản phẩm',
                      trailing: InkWell(
                        onTap: () => _clearCategoryFilter(productProvider),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: Text(
                            'Xem tất cả',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 124,
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
                      scrollDirection: Axis.horizontal,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            mainAxisExtent: 156,
                          ),
                      itemCount: _homeCategories.length,
                      itemBuilder: (context, index) {
                        final category = _homeCategories[index];
                        final selected = _isCategorySelected(category);
                        return CategoryItem(
                          icon: category.icon,
                          label: category.label,
                          selected: selected,
                          onTap: () =>
                              _applyCategoryFilter(productProvider, category),
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                    child: _SectionHeader(
                      title: 'Gợi ý hôm nay',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1E8),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'Mới nhất',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (productProvider.isLoading &&
                    productProvider.products.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (productProvider.errorMessage != null &&
                    productProvider.products.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ErrorView(
                      message: productProvider.errorMessage!,
                      onRetry: productProvider.fetchInitialProducts,
                    ),
                  )
                else if (products.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyView(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final product = products[index];
                        return _ProductCard(product: product);
                      }, childCount: products.length),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.63,
                          ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: _LoadMoreFooter(
                    isLoadingMore: productProvider.isLoadingMore,
                    hasMore: productProvider.hasMore,
                    hasItems: productProvider.products.isNotEmpty,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HomeCategory {
  const _HomeCategory({
    required this.label,
    required this.icon,
    this.providerCategory,
    this.searchKeyword,
  });

  final String label;
  final IconData icon;
  final String? providerCategory;
  final String? searchKeyword;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.trailing});

  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        trailing,
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                      child: SizedBox.expand(
                        child: Image.network(
                          product.image,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) {
                              return child;
                            }

                            return Container(
                              color: Colors.grey.shade200,
                              child: Stack(
                                fit: StackFit.expand,
                                children: <Widget>[
                                  Opacity(opacity: 0.35, child: child),
                                  const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEE4D2D),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.tag,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            context.read<CartProvider>().addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã thêm sản phẩm vào giỏ hàng'),
                                duration: Duration(milliseconds: 800),
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.add_shopping_cart_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.25,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatPrice(product.price),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Đã bán ${_formatSold(product.sold)}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({
    required this.isLoadingMore,
    required this.hasMore,
    required this.hasItems,
  });

  final bool isLoadingMore;
  final bool hasMore;
  final bool hasItems;

  @override
  Widget build(BuildContext context) {
    if (!hasItems) {
      return const SizedBox(height: 20);
    }

    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.2)),
      );
    }

    if (!hasMore) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(12, 6, 12, 16),
        child: Center(
          child: Text(
            'Bạn đã xem hết sản phẩm',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return const SizedBox(height: 18);
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.wifi_off_rounded,
              size: 60,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Không có sản phẩm phù hợp',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
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

  return '${buffer.toString()}đ';
}

String _formatSold(int sold) {
  if (sold >= 1000000) {
    return '${(sold / 1000000).toStringAsFixed(1)}m';
  }
  if (sold >= 1000) {
    return '${(sold / 1000).toStringAsFixed(1)}k';
  }
  return '$sold';
}
