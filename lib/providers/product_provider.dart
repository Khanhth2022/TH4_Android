import 'package:flutter/foundation.dart';

import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  static const String allCategory = 'Tất cả';
  static const int _pageSize = 8;

  final ApiService _apiService;

  final List<ProductModel> _products = <ProductModel>[];
  final List<String> _categories = <String>[allCategory];

  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _searchQuery = '';
  String _selectedCategory = allCategory;
  String? _errorMessage;
  ProductModel? _selectedProduct;

  List<ProductModel> get products => List<ProductModel>.unmodifiable(_products);
  List<String> get categories => List<String>.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String? get errorMessage => _errorMessage;
  ProductModel? get selectedProduct => _selectedProduct;

  List<ProductModel> get filteredProducts {
    return _products
        .where((product) {
          final matchesCategory =
              _selectedCategory == allCategory ||
              product.category.toLowerCase() == _selectedCategory.toLowerCase();

          final normalizedQuery = _searchQuery.trim().toLowerCase();
          final matchesQuery =
              normalizedQuery.isEmpty ||
              product.title.toLowerCase().contains(normalizedQuery) ||
              product.category.toLowerCase().contains(normalizedQuery);

          return matchesCategory && matchesQuery;
        })
        .toList(growable: false);
  }

  Future<void> fetchInitialProducts() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPage = 1;
      final fetched = await _apiService.fetchProducts(
        page: _currentPage,
        limit: _pageSize,
      );
      _products
        ..clear()
        ..addAll(fetched);
      _hasMore = fetched.length == _pageSize;
      _rebuildCategories();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProducts() async {
    _isRefreshing = true;
    notifyListeners();

    try {
      _currentPage = 1;
      _errorMessage = null;
      final fetched = await _apiService.fetchProducts(
        page: _currentPage,
        limit: _pageSize,
      );
      _products
        ..clear()
        ..addAll(fetched);
      _hasMore = fetched.length == _pageSize;
      _rebuildCategories();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreProducts() async {
    if (_isLoading || _isLoadingMore || !_hasMore) {
      return;
    }

    _isLoadingMore = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final fetched = await _apiService.fetchProducts(
        page: nextPage,
        limit: _pageSize,
      );

      if (fetched.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        _products.addAll(fetched);
        _hasMore = fetched.length == _pageSize;
        _rebuildCategories();
      }
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> fetchProductDetail(int productId) async {
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedProduct = await _apiService.fetchProductDetail(productId);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      notifyListeners();
    }
  }

  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }

  void _rebuildCategories() {
    final categorySet = _products.map((product) => product.category).toSet();
    _categories
      ..clear()
      ..add(allCategory)
      ..addAll(categorySet);

    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory = allCategory;
    }
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
