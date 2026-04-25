class Product {
  final int id;
  final String title;
  final String description;
  final String image;
  final double price;
  final double rating;
  final String category;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.price,
    required this.rating,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      image: json['thumbnail'] ?? "",
      price: (json['price'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      category: (json['category'] ?? "Other").toString(),
    );
  }
}
