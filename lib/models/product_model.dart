class ProductModel {
  String productId;
  DateTime createdAt;
  String name;
  String description;
  String imageUrl;
  double price;
  String category;

  ProductModel({
    required this.productId,
    required this.createdAt,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['uid'],
      createdAt: DateTime.parse(json['created_at']),
      name: json['name'],
      description: json['description'],
      imageUrl: json['image'],
      price: json['price'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': productId,
      'created_at': createdAt.toIso8601String(),
      'name': name,
      'description': description,
      'image': imageUrl,
      'price': price,
      'category': category,
    };
  }
}
