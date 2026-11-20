import 'product.dart';

/// Article contenu dans le panier d'achat.
class CartItem {
  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  final String id;
  final Product product;
  final int quantity;

  /// Prix total pour cet article.
  double get totalPrice => product.price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: (json['id'] ?? '').toString(),
      product: json['product'] != null
          ? Product.fromJson(json['product'] as Map<String, dynamic>)
          : Product(
              id: (json['productId'] ?? '').toString(),
              name: (json['productName'] ?? json['name'] ?? '') as String,
              price: (json['unitPrice'] ?? json['price'] as num?)?.toDouble() ?? 0.0,
              currency: (json['currency'] as String?) ?? 'EUR',
              photoUrl: json['photoUrl'] as String?,
            ),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}
