import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cart.dart';
import 'marketplace_page.dart';

/// Provider gérant le panier d'achat de l'utilisateur avec Riverpod AsyncNotifier.
final cartProvider = AsyncNotifierProvider<CartNotifier, Cart>(CartNotifier.new);

class CartNotifier extends AsyncNotifier<Cart> {
  @override
  Future<Cart> build() async {
    return ref.watch(marketplaceApiProvider).getCart();
  }

  /// Rafraîchit le panier.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(marketplaceApiProvider).getCart());
  }

  /// Ajoute un produit au panier.
  Future<void> addItem(String productId, int quantity) async {
    final previousState = state.value;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updatedCart = await ref.read(marketplaceApiProvider).addToCart(productId, quantity);
      return updatedCart;
    });
    if (state.hasError && previousState != null) {
      state = AsyncValue.data(previousState);
    }
  }

  /// Modifie la quantité d'un article du panier.
  Future<void> updateQuantity(String itemId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(itemId);
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(marketplaceApiProvider).updateCartItem(itemId, quantity),
    );
  }

  /// Supprime un article du panier.
  Future<void> removeItem(String itemId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(marketplaceApiProvider).removeFromCart(itemId),
    );
  }

  /// Vide entièrement le panier.
  Future<void> clear() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(marketplaceApiProvider).clearCart();
      return const Cart();
    });
  }
}
