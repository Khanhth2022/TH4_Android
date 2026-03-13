class ProductModel {
  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    this.rating = 0,
    this.ratingCount = 0,
    this.sold = 0,
    this.tag = 'Mall',
  });

  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double rating;
  final int ratingCount;
  final int sold;
  final String tag;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final ratingJson = json['rating'] as Map<String, dynamic>?;
    return ProductModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '') as String,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      description: (json['description'] ?? '') as String,
      category: (json['category'] ?? '') as String,
      image: (json['image'] ?? '') as String,
      rating: (ratingJson?['rate'] as num?)?.toDouble() ?? 0,
      ratingCount: (ratingJson?['count'] as num?)?.toInt() ?? 0,
      sold: (ratingJson?['count'] as num?)?.toInt() ?? 0,
      tag: 'Mall',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      'rating': {'rate': rating, 'count': ratingCount},
      'sold': sold,
      'tag': tag,
    };
  }
}
