class Product {
  final String id;
  final String name;
  final String? description;
  final String? imagePath;
  final String? sku;
  final String? categoryId;
  final String? categoryName;
  final double purchasePrice;
  final double sellingPrice;
  final double taxRate;
  final int stock;
  final int reorderLevel;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    this.description,
    this.imagePath,
    this.sku,
    this.categoryId,
    this.categoryName,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.taxRate,
    required this.stock,
    required this.reorderLevel,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isInStock => stock > 0;

  bool get isLowStock {
    if (!isInStock) return false;
    if (reorderLevel <= 0) return false;
    return stock <= reorderLevel;
  }
}
