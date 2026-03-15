import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://dummyjson.com';
  final http.Client _client;

  Future<List<ProductModel>> fetchProducts({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _client.get(Uri.parse('$_baseUrl/products?limit=$limit&skip=${(page - 1) * limit}'));

    if (response.statusCode != 200) {
      throw Exception('Không thể tải danh sách sản phẩm');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final products = decoded['products'] as List<dynamic>? ?? [];
    return products.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ProductModel> fetchProductDetail(int id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/products/$id'));
    if (response.statusCode != 200) {
      throw Exception('Không thể tải chi tiết sản phẩm');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return ProductModel.fromJson(decoded);
  }

  void dispose() {
    _client.close();
  }
}
