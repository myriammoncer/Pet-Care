import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/order.dart';
import 'marketplace_page.dart';

/// Provider gérant la liste des commandes de l'utilisateur.
final ordersProvider = AsyncNotifierProvider<OrdersNotifier, List<Order>>(OrdersNotifier.new);

class OrdersNotifier extends AsyncNotifier<List<Order>> {
  @override
  Future<List<Order>> build() async {
    return ref.watch(marketplaceApiProvider).getOrders();
  }

  /// Rafraîchit l'historique des commandes.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(marketplaceApiProvider).getOrders());
  }

  /// Crée une nouvelle commande à partir des informations de livraison.
  Future<Order> placeOrder(Map<String, dynamic> checkoutData) async {
    final order = await ref.read(marketplaceApiProvider).createOrder(checkoutData);
    await refresh();
    return order;
  }
}
