class ProductCategory {
  final String id;
  final String name;
  final String icon;
  final String colorHex;
  final int itemCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorHex,
    this.itemCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });
}
