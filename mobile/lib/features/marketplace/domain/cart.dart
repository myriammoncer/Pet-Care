import 'cart_item.dart';

/// Panier d'achat complet.
class Cart {
  const Cart({
    this.id,
    this.items = const [],
    this.currency = 'EUR',
  });

  final String? id;
  final List<CartItem> items;
  final String currency;

  /// Calcul dynamique du prix total.
  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Nombre total d'articles dans le panier.
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory Cart.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return Cart(
      id: json['id']?.toString(),
      items: rawItems.map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList(),
      currency: (json['currency'] as String?) ?? 'EUR',
    );
  }
}
