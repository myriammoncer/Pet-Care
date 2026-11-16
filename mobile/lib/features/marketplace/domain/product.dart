/// Entité métier représentant un produit de la boutique.
class Product {
  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.currency = 'EUR',
    this.stock,
    this.photoUrl,
    this.category,
    this.active = true,
  });

  final String id;
  final String name;
  final String? description;
  final double price;
  final String currency;
  final int? stock;
  final String? photoUrl;
  final String? category;
  final bool? active;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: (json['currency'] as String?) ?? 'EUR',
      stock: json['stock'] as int?,
      photoUrl: json['photoUrl'] as String?,
      category: json['category'] as String?,
      active: json['active'] as bool? ?? json['isActive'] as bool? ?? true,
    );
  }
}
