import 'cart_item.dart';

/// Statut d'une commande.
enum OrderStatus {
  pending,
  paid,
  shipped,
  delivered,
  cancelled;

  static OrderStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'PAID':
        return OrderStatus.paid;
      case 'SHIPPED':
        return OrderStatus.shipped;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.paid:
        return 'Payée';
      case OrderStatus.shipped:
        return 'Expédiée';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
    }
  }
}

/// Modèle représentant une commande passée.
class Order {
  const Order({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.totalAmount,
    this.currency = 'EUR',
    this.items = const [],
    this.shippingAddress,
  });

  final String id;
  final DateTime createdAt;
  final OrderStatus status;
  final double totalAmount;
  final String currency;
  final List<CartItem> items;
  final String? shippingAddress;

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return Order(
      id: (json['id'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      status: OrderStatus.fromString(json['status'] as String?),
      totalAmount: (json['totalAmount'] ?? json['total'] as num?)?.toDouble() ?? 0.0,
      currency: (json['currency'] as String?) ?? 'EUR',
      items: rawItems.map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList(),
      shippingAddress: json['shippingAddress'] as String? ?? json['address'] as String?,
    );
  }
}
