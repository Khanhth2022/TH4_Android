class ProductModel {
  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.images,
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
  final List<String> images;
  final double rating;
  final int ratingCount;
  final int sold;
  final String tag;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '') as String,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      description: (json['description'] ?? '') as String,
      category: (json['category'] ?? '') as String,
      image: (json['thumbnail'] ?? '') as String,
      images: List<String>.from(json['images'] ?? []),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: (json['stock'] as num?)?.toInt() ?? 0, // DummyJSON không có ratingCount, dùng stock làm ví dụ
      sold: 0,
      tag: 'Mall',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'description': description,
    'category': category,
    'image': image,
    'images': images,
    'rating': rating,
    'ratingCount': ratingCount,
    'sold': sold,
    'tag': tag,
  };
}
