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
    final dynamic ratingRaw = json['rating'];
    final double parsedRating;
    final int parsedRatingCount;

    if (ratingRaw is num) {
      parsedRating = ratingRaw.toDouble();
      parsedRatingCount =
          (json['ratingCount'] as num?)?.toInt() ??
          (json['stock'] as num?)?.toInt() ??
          0;
    } else if (ratingRaw is Map<String, dynamic>) {
      parsedRating = (ratingRaw['rate'] as num?)?.toDouble() ?? 0;
      parsedRatingCount =
          (ratingRaw['count'] as num?)?.toInt() ??
          (json['stock'] as num?)?.toInt() ??
          0;
    } else {
      parsedRating = 0;
      parsedRatingCount =
          (json['ratingCount'] as num?)?.toInt() ??
          (json['stock'] as num?)?.toInt() ??
          0;
    }

    final dynamic imagesRaw = json['images'];
    final List<String> parsedImages = imagesRaw is List
        ? imagesRaw.map((e) => e.toString()).toList(growable: false)
        : <String>[];

    final String parsedImage = (json['thumbnail'] ?? json['image'] ?? '')
        .toString();

    return ProductModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString(),
      price:
          (json['price'] as num?)?.toDouble() ??
          double.tryParse((json['price'] ?? '').toString()) ??
          0,
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      image: parsedImage,
      images: parsedImages.isNotEmpty
          ? parsedImages
          : (parsedImage.isNotEmpty ? <String>[parsedImage] : <String>[]),
      rating: parsedRating,
      ratingCount: parsedRatingCount,
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
