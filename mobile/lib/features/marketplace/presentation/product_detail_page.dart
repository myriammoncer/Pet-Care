import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/product_image.dart';
import '../domain/product.dart';
import 'cart_controller.dart';
import 'marketplace_page.dart';

/// Provider pour charger un produit spécifique par son ID.
final productDetailProvider = FutureProvider.family<Product, String>((ref, id) async {
  return ref.watch(marketplaceApiProvider).getById(id);
});

class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  int _quantity = 1;

  void _incrementQuantity(int? maxStock) {
    if (maxStock == null || _quantity < maxStock) {
      setState(() => _quantity++);
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final cartAsync = ref.watch(cartProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF1F2937)),
            ),
            onPressed: () => context.pop(),
          ),
        ),
        title: const Text(
          'Détail du produit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0C000000),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Badge(
                  backgroundColor: theme.colorScheme.primary,
                  label: Text('${cartAsync.value?.itemCount ?? 0}'),
                  isLabelVisible: (cartAsync.value?.itemCount ?? 0) > 0,
                  child: const Icon(Icons.shopping_bag_outlined, size: 18, color: Color(0xFF1F2937)),
                ),
              ),
              onPressed: () => context.push('/cart'),
            ),
          ),
        ],
      ),
      body: AsyncView(
        value: productAsync,
        onRetry: () => ref.invalidate(productDetailProvider(widget.productId)),
        data: (product) {
          final isOutOfStock = product.stock != null && product.stock! <= 0;
          final itemPrice = (product.price * _quantity).toStringAsFixed(2);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Grande Showcase Image Luxe ───
                      Container(
                        height: 320,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0xFFEFF1F4), width: 1),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 24,
                              spreadRadius: 0,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Hero(
                                  tag: 'product_${product.id}',
                                  child: ProductImage(
                                    photoUrl: product.photoUrl,
                                    category: product.category,
                                    identifier: product.name,
                                    fit: BoxFit.cover,
                                    fallbackIconSize: 72,
                                  ),
                                ),
                              ),
                              // Badge de stock discret
                              Positioned(
                                top: 16,
                                left: 16,
                                child: _buildStockPill(product.stock),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ─── Catégorie ───
                      if (product.category != null && product.category!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.category!.replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),

                      // ─── Nom du produit ───
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          letterSpacing: -0.4,
                          height: 1.25,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ─── Prix unitaire ───
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${product.price.toStringAsFixed(2)} ${product.currency}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'TVA incluse',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFEFF1F4), height: 1),
                      const SizedBox(height: 20),

                      // ─── Description ───
                      const Text(
                        'Détails du produit',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        product.description != null && product.description!.isNotEmpty
                            ? product.description!
                            : 'Cet article a été soigneusement sélectionné pour le bien-être, le confort et la vitalité de votre compagnon à quatre pattes.',
                        style: const TextStyle(
                          color: Color(0xFF4B5563),
                          fontSize: 14,
                          height: 1.6,
                          letterSpacing: -0.1,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ─── Engagements qualité ───
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF0F2F5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildFeature(Icons.verified_outlined, 'Qualité certifiée'),
                            _buildFeature(Icons.local_shipping_outlined, 'Livraison rapide'),
                            _buildFeature(Icons.lock_outline, 'Paiement sécurisé'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Barre d'action fixe inférieure ───
              Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 20,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      // Sélecteur de quantité minimaliste
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_rounded, size: 18),
                              color: const Color(0xFF374151),
                              onPressed: _quantity > 1 ? _decrementQuantity : null,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_rounded, size: 18),
                              color: const Color(0xFF374151),
                              onPressed: (product.stock == null || _quantity < product.stock!)
                                  ? () => _incrementQuantity(product.stock)
                                  : null,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Bouton d'ajout
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: isOutOfStock
                                ? null
                                : () async {
                                    final success = await ref
                                        .read(cartProvider.notifier)
                                        .addItem(product.id, _quantity);
                                    if (!context.mounted) return;

                                    if (!success) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text(
                                          'Impossible d\'ajouter au panier. '
                                          'Veuillez vous connecter.',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                        backgroundColor: Color(0xFFEF4444),
                                      ));
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          backgroundColor: const Color(0xFF111827),
                                          content: Row(
                                            children: [
                                              const Icon(Icons.check_circle_rounded,
                                                  color: Colors.white, size: 20),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  '$_quantity x ${product.name} ajouté ($itemPrice ${product.currency})',
                                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                                ),
                                              ),
                                            ],
                                          ),
                                          action: SnackBarAction(
                                            label: 'Panier',
                                            textColor: theme.colorScheme.primary,
                                            onPressed: () {
                                              if (context.mounted) {
                                                Future.microtask(() {
                                                  if (context.mounted) {
                                                    GoRouter.of(context).push('/cart');
                                                  }
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.shopping_bag_outlined, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  isOutOfStock
                                      ? 'Indisponible'
                                      : 'Ajouter • $itemPrice ${product.currency}',
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStockPill(int? stock) {
    final inStock = stock == null || stock > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: inStock ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: inStock ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: inStock ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            inStock
                ? (stock != null ? '$stock en stock' : 'En stock')
                : 'Épuisé',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: inStock ? const Color(0xFF065F46) : const Color(0xFF991B1B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6B7280)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
