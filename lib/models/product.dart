class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final String imageUrl;
  final bool isDigital;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.isDigital,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Meditation',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl: json['image_url']?.toString() ?? '',
      isDigital: json['is_digital'] == 1 || json['is_digital'] == true || json['is_digital'].toString() == '1',
    );
  }
}
