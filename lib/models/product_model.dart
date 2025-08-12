import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final double price;

  @HiveField(5)
  final String brand;

  @HiveField(6)
  final double rating;

  @HiveField(7)
  final List<String> images;

  @HiveField(8)
  final String thumbnail;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.brand,
    required this.rating,
    required this.images,
    required this.thumbnail,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      brand: json['brand'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      thumbnail: json['thumbnail'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'brand': brand,
      'rating': rating,
      'images': images,
      'thumbnail': thumbnail,
    };
  }
}

@HiveType(typeId: 1)
class CachedProductData extends HiveObject {
  @HiveField(0)
  final List<Product> products;

  @HiveField(1)
  final DateTime cachedAt;

  CachedProductData({
    required this.products,
    required this.cachedAt,
  });

  bool get isStale {
    final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
    return cachedAt.isBefore(fiveMinutesAgo);
  }
}
