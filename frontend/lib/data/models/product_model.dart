class ProductMedia {
  final String url;
  final String type; // 'image' | 'video'
  final String publicId;

  ProductMedia({required this.url, this.type = 'image', this.publicId = ''});

  factory ProductMedia.fromJson(Map<String, dynamic> json) {
    return ProductMedia(
      url: json['url'] ?? '',
      type: json['type'] ?? 'image',
      publicId: json['publicId'] ?? '',
    );
  }
}

class ProductModel {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String shortDescription;
  final double price;
  final double compareAtPrice;
  final String category;
  final List<String> tags;
  final int stock;
  final String sku;
  final List<ProductMedia> media;
  final bool featured;
  final bool handmade;
  final List<String> materials;
  final String color;
  final String brand;
  final String dimensions;
  final String weight;
  final double rating;
  final int reviewCount;
  final bool active;
  final bool bestSeller;
  final bool newArrival;

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.shortDescription = '',
    required this.price,
    this.compareAtPrice = 0,
    required this.category,
    this.tags = const [],
    this.stock = 0,
    this.sku = '',
    this.media = const [],
    this.featured = false,
    this.handmade = true,
    this.materials = const [],
    this.color = '',
    this.brand = 'WOOD CARVERS',
    this.dimensions = '',
    this.weight = '',
    this.rating = 4.7,
    this.reviewCount = 0,
    this.active = true,
    this.bestSeller = false,
    this.newArrival = false,
  });

  String get thumbnailUrl => media.isNotEmpty ? media.first.url : '';

  bool get onSale => compareAtPrice > price && compareAtPrice > 0;

  int get discountPercent =>
      onSale ? (((compareAtPrice - price) / compareAtPrice) * 100).round() : 0;

  bool get inStock => stock > 0;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      compareAtPrice: (json['compareAtPrice'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      tags: (json['tags'] as List? ?? []).cast<String>(),
      stock: json['stock'] ?? 0,
      sku: json['sku'] ?? '',
      media: (json['media'] as List? ?? [])
          .map((m) => ProductMedia.fromJson(m))
          .toList(),
      featured: json['featured'] ?? false,
      handmade: json['handmade'] ?? true,
      materials: (json['materials'] as List? ?? []).cast<String>(),
      color: json['color'] ?? '',
      brand: json['brand'] ?? 'WOOD CARVERS',
      dimensions: json['dimensions'] ?? '',
      weight: json['weight'] ?? '',
      rating: (json['rating'] ?? 4.7).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      active: json['active'] ?? true,
      bestSeller: json['bestSeller'] ?? false,
      newArrival: json['newArrival'] ?? false,
    );
  }
}
