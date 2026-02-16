class Product {
  final String id;
  final String name;
  final String description;
  final String? image;
  final int stock;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.stock,
    required this.price,
    this.image,
  });
}
