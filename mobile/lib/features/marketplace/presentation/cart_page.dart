import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/product_image.dart';
import '../domain/cart_item.dart';
import 'cart_controller.dart';

/// Panier d'achat — design haut de gamme avec calcul taxes.
class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  // ── Palette luxe ──
  static const _champagne = Color(0xFFD4A574);
  static const _champagneLight = Color(0xFFF8F0E8);
  static const _dark = Color(0xFF111827);
  static const _muted = Color(0xFF6B7280);
  static const _bg = Color(0xFFFAFAFB);
  static const _border = Color(0xFFF0F1F3);
  static const _tvaTaux = 0.20;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'MON PANIER',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: _dark,
          ),
        ),
        centerTitle: true,
        actions: [
          cartAsync.maybeWhen(
            data: (cart) => cart.items.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Color(0xFF9CA3AF)),
                    tooltip: 'Vider le panier',
                    onPressed: () => _confirmClearCart(context, ref),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
      ),
      body: AsyncView(
        value: cartAsync,
        onRetry: () => ref.read(cartProvider.notifier).refresh(),
        data: (cart) {
          if (cart.items.isEmpty) {
            return _buildEmptyState(context);
          }

          final subtotal = cart.totalPrice;
          final tva = subtotal * _tvaTaux;
          final shipping = subtotal > 50 ? 0.0 : 5.99;
          final total = subtotal + tva + shipping;

          return Column(
            children: [
              // ── Liste d'articles ──
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  itemCount: cart.items.length,
                  itemBuilder: (_, index) {
                    final item = cart.items[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < cart.items.length - 1 ? 12 : 0,
                      ),
                      child: _CartItemTile(item: item),
                    );
                  },
                ),
              ),

              // ── Récapitulatif & CTA ──
              _buildBottomSummary(
                context: context,
                subtotal: subtotal,
                tva: tva,
                shipping: shipping,
                total: total,
                itemCount: cart.itemCount,
                currency: cart.currency,
              ),
            ],
          );
        },
      ),
    );
  }

  // ── État vide ──
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: _champagneLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 44,
                color: _champagne,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Votre panier est vide',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _dark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Découvrez notre collection premium\npour le bien-être de vos compagnons.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: _muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/marketplace'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _dark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                ),
                icon: const Icon(Icons.storefront_outlined, size: 20),
                label: const Text(
                  'Explorer la boutique',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Récapitulatif du bas ──
  Widget _buildBottomSummary({
    required BuildContext context,
    required double subtotal,
    required double tva,
    required double shipping,
    required double total,
    required int itemCount,
    required String currency,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lignes de prix
            _PriceRow(label: 'Sous-total ($itemCount article${itemCount > 1 ? 's' : ''})', value: subtotal),
            const SizedBox(height: 6),
            _PriceRow(label: 'TVA (20%)', value: tva),
            const SizedBox(height: 6),
            _PriceRow(
              label: 'Livraison',
              value: shipping,
              isFree: shipping == 0,
              freeLabel: 'Gratuite',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: _border, height: 1),
            ),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total TTC',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _dark,
                  ),
                ),
                Text(
                  '${total.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _champagne,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),

            // Livraison gratuite info
            if (subtotal < 50)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _champagneLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_shipping_outlined,
                          size: 14, color: _champagne),
                      const SizedBox(width: 6),
                      Text(
                        'Plus que ${(50 - subtotal).toStringAsFixed(2)} € pour la livraison gratuite',
                        style: TextStyle(
                          fontSize: 12,
                          color: _champagne,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // CTA Commander
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => context.push('/checkout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _dark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_rounded, size: 18),
                    const SizedBox(width: 10),
                    const Text(
                      'Procéder au paiement',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearCart(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Vider le panier',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Voulez-vous vraiment retirer tous les articles ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler', style: TextStyle(color: _muted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref.read(cartProvider.notifier).clear();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Vider'),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// CARTE ARTICLE
// ═════════════════════════════════════════════════════════════

class _CartItemTile extends ConsumerWidget {
  const _CartItemTile({required this.item});

  final CartItem item;

  static const _dark = Color(0xFF111827);
  static const _muted = Color(0xFF6B7280);
  static const _champagne = Color(0xFFD4A574);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = item.product;
    final itemTotal = '${item.totalPrice.toStringAsFixed(2)} €';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0F1F3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 16,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Vignette image ──
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ProductImage(
              photoUrl: product.photoUrl,
              category: product.category,
              identifier: product.name,
              fallbackIconSize: 32,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 14),

          // ── Détails ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                    color: _dark,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.price.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),

                // Sélecteur de quantité
                Container(
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _QuantityBtn(
                        icon: Icons.remove_rounded,
                        onTap: () => ref
                            .read(cartProvider.notifier)
                            .updateQuantity(item.id, item.quantity - 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: _dark,
                          ),
                        ),
                      ),
                      _QuantityBtn(
                        icon: Icons.add_rounded,
                        onTap: () => ref
                            .read(cartProvider.notifier)
                            .updateQuantity(item.id, item.quantity + 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Total + supprimer ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () =>
                    ref.read(cartProvider.notifier).removeItem(item.id),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 14, color: Color(0xFFEF4444)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                itemTotal,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: _champagne,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bouton +/- pour la quantité.
class _QuantityBtn extends StatelessWidget {
  const _QuantityBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: const Color(0xFF374151)),
      ),
    );
  }
}

/// Ligne de prix dans le récapitulatif.
class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.isFree = false,
    this.freeLabel,
  });

  final String label;
  final double value;
  final bool isFree;
  final String? freeLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        Text(
          isFree ? (freeLabel ?? 'Gratuit') : '${value.toStringAsFixed(2)} €',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isFree ? const Color(0xFF059669) : const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}
