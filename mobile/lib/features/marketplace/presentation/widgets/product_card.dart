import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/product_image.dart';
import '../../domain/product.dart';
import '../cart_controller.dart';

/// Carte produit élégante et minimaliste, style boutique haut de gamme
class ProductCard extends ConsumerWidget {
  const ProductCard({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isOutOfStock = product.stock != null && product.stock! <= 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF0F1F3),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            spreadRadius: 0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push('/marketplace/${product.id}'),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Image Produit ───
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Hero(
                          tag: 'product_${product.id}',
                          child: ProductImage(
                            photoUrl: product.photoUrl,
                            category: product.category,
                            identifier: product.name,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      // Badge rupture éventuel
                      if (isOutOfStock)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'ÉPUISÉ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ─── Catégorie fine ───
                if (product.category != null && product.category!.isNotEmpty)
                  Text(
                    product.category!.replaceAll('_', ' ').toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8C95A3),
                      letterSpacing: 0.8,
                    ),
                  ),

                const SizedBox(height: 4),

                // ─── Titre du Produit ───
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1D20),
                    height: 1.25,
                    letterSpacing: -0.2,
                  ),
                ),

                const SizedBox(height: 10),

                // ─── Prix & Bouton Ajout rapide ───
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(2)} ${product.currency}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                            letterSpacing: -0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ],
                    ),
                    // Bouton ajout panier rapide épuré
                    Material(
                      color: isOutOfStock
                          ? const Color(0xFFF1F3F5)
                          : theme.colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: isOutOfStock
                            ? null
                            : () async {
                                final success = await ref
                                    .read(cartProvider.notifier)
                                    .addItem(product.id, 1);
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      duration: const Duration(milliseconds: 1600),
                                      content: Text(
                                        '${product.name} ajouté au panier',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  );
                                }
                              },
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: Icon(
                            Icons.add_shopping_cart_rounded,
                            size: 17,
                            color: isOutOfStock
                                ? const Color(0xFFBAC2CB)
                                : theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

