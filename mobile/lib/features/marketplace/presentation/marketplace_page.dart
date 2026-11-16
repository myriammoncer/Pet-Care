import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/product_assets.dart';
import '../../../core/di/providers.dart';
import '../data/marketplace_api.dart';
import '../domain/product.dart';
import 'cart_controller.dart';
import 'widgets/category_selector.dart';
import 'widgets/product_card.dart';

/// Fournit l'API Marketplace.
final marketplaceApiProvider = Provider<MarketplaceApi>(
  (ref) => MarketplaceApi(ref.watch(dioProvider)),
);

/// Récupère le catalogue de produits.
final productsProvider = FutureProvider<List<Product>>((ref) async {
  return ref.watch(marketplaceApiProvider).list();
});

/// Identifiant de la catégorie sélectionnée ('ALL' par défaut).
final selectedCategoryProvider = StateProvider<String>((ref) => 'ALL');

class MarketplacePage extends ConsumerStatefulWidget {
  const MarketplacePage({super.key});

  @override
  ConsumerState<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends ConsumerState<MarketplacePage> {
  void _injectMagicProducts(BuildContext context) async {
    // ═══════════════════════════════════════════════════════════════
    // 31 produits premium — un par image, classés par catégorie
    // ═══════════════════════════════════════════════════════════════
    final fakeProducts = [
      // ───────── ALIMENTATION (10 produits) ─────────
      {
        "name": "Croquettes Bio Premium Saumon",
        "description": "Riches en saumon frais et super-aliments, formulées sans céréales, sac de 5 kg pour une vitalité optimale et un pelage éclatant.",
        "price": 34.99,
        "currency": "EUR",
        "stock": 20,
        "category": "ALIMENTATION",
        "photoUrl": ProductAssets.alimentationDogFood,
        "active": true
      },
      {
        "name": "Pack Découverte Made in France",
        "description": "Assortiment gourmand fabriqué en France : croquettes, pâtées et friandises naturelles pour chien exigeant.",
        "price": 42.90,
        "currency": "EUR",
        "stock": 12,
        "category": "ALIMENTATION",
        "photoUrl": ProductAssets.alimentationPackDecouverte,
        "active": true
      },
      {
        "name": "Croquettes Chat Adulte Poulet & Riz",
        "description": "Recette équilibrée à base de poulet fermier et riz complet, enrichie en taurine pour la santé cardiaque du chat.",
        "price": 27.50,
        "currency": "EUR",
        "stock": 35,
        "category": "ALIMENTATION",
        "photoUrl": ProductAssets.alimentationCroquettesChats,
        "active": true
      },
      {
        "name": "Pâtée Gold Miel & Fusion Nutribird",
        "description": "Alimentation premium pour oiseaux, enrichie au miel naturel et vitamines essentielles pour un plumage vibrant.",
        "price": 18.90,
        "currency": "EUR",
        "stock": 40,
        "category": "ALIMENTATION",
        "photoUrl": ProductAssets.alimentationGoldPatee,
        "active": true
      },
      {
        "name": "Alimentation Naturelle Chiot",
        "description": "Formule spéciale croissance avec DHA, protéines de haute qualité et calcium pour le développement osseux du chiot.",
        "price": 31.00,
        "currency": "EUR",
        "stock": 18,
        "category": "ALIMENTATION",
        "photoUrl": ProductAssets.alimentationAdobeStock,
        "active": true
      },
      {
        "name": "Repas Complet Bio pour Chat",
        "description": "Nourriture complète certifiée bio, à base de viande fraîche et légumes de saison, sans conservateurs artificiels.",
        "price": 23.50,
        "currency": "EUR",
        "stock": 28,
        "category": "ALIMENTATION",
        "photoUrl": ProductAssets.alimentationChatGpt,
        "active": true
      },
      {
        "name": "Croquettes Hypoallergéniques Agneau",
        "description": "Formule mono-protéine à l'agneau pour les chiens sensibles, sans gluten ni additifs, digestion douce garantie.",
        "price": 38.90,
        "currency": "EUR",
        "stock": 15,
        "category": "ALIMENTATION",
        "photoUrl": ProductAssets.alimentationDietGuide,
        "active": true
      },
      {
        "name": "Friandises Dentaires Bâtonnets",
        "description": "Bâtonnets à mâcher enrichis en menthe et enzymes naturelles pour une haleine fraîche et des dents saines.",
        "price": 9.90,
        "currency": "EUR",
        "stock": 55,
        "category": "ALIMENTATION",
        "photoUrl": ProductAssets.alimentationImages,
        "active": true
      },
      {
        "name": "Boîtes Pâté Gourmet Bœuf & Légumes",
        "description": "Pâté onctueux au bœuf sélectionné et petits légumes du jardin, source de protéines nobles et oméga-3.",
        "price": 15.90,
        "currency": "EUR",
        "stock": 32,
        "category": "ALIMENTATION",
        "photoUrl": ProductAssets.alimentationImages1,
        "active": true
      },
      {
        "name": "Complément Alimentaire Vitalité+",
        "description": "Supplément en poudre aux vitamines B, zinc et levure de bière pour renforcer l'immunité et la beauté du poil.",
        "price": 22.00,
        "currency": "EUR",
        "stock": 24,
        "category": "ALIMENTATION",
        "photoUrl": ProductAssets.alimentationImages2,
        "active": true
      },

      // ───────── JOUETS (5 produits) ─────────
      {
        "name": "Balle Rebondissante Haute Résistance",
        "description": "Caoutchouc naturel non toxique, conçue pour les séances de jeu intenses et interactives avec votre compagnon.",
        "price": 14.50,
        "currency": "EUR",
        "stock": 45,
        "category": "JOUETS",
        "photoUrl": ProductAssets.jouetsBalle,
        "active": true
      },
      {
        "name": "Peluche Artisanale Sur Mesure",
        "description": "Peluche douce cousue main avec rembourrage hypoallergénique, compagnon câlin idéal pour chiot et petit chien.",
        "price": 24.90,
        "currency": "EUR",
        "stock": 20,
        "category": "JOUETS",
        "photoUrl": ProductAssets.jouetsPeluche,
        "active": true
      },
      {
        "name": "Corde Tressée Multi-Nœuds",
        "description": "Corde en coton naturel tressé résistant, parfaite pour le tir à la corde et le nettoyage naturel des dents.",
        "price": 11.90,
        "currency": "EUR",
        "stock": 60,
        "category": "JOUETS",
        "photoUrl": ProductAssets.jouets3009665,
        "active": true
      },
      {
        "name": "Jouet Distributeur de Friandises",
        "description": "Jouet interactif intelligent qui stimule l'instinct de recherche et distribue des récompenses progressivement.",
        "price": 19.90,
        "currency": "EUR",
        "stock": 30,
        "category": "JOUETS",
        "photoUrl": ProductAssets.jouets61BT,
        "active": true
      },
      {
        "name": "Frisbee Souple Ultra-Léger",
        "description": "Disque volant en silicone souple, doux pour les gencives et ultra-visible grâce à ses couleurs vives.",
        "price": 12.50,
        "currency": "EUR",
        "stock": 38,
        "category": "JOUETS",
        "photoUrl": ProductAssets.jouetsVoDb,
        "active": true
      },

      // ───────── NICHE & COUCHAGE (6 produits) ─────────
      {
        "name": "Niche Artisanale en Bois Noble",
        "description": "Finitions artisanales en bois massif traité, isolation thermique naturelle et toit amovible pour un entretien facile.",
        "price": 129.00,
        "currency": "EUR",
        "stock": 5,
        "category": "NICHE_COUCHAGE",
        "photoUrl": ProductAssets.couchageNicheBois,
        "active": true
      },
      {
        "name": "Coussin Ovale Velours Premium",
        "description": "Coussin moelleux en velours lavable avec mousse à mémoire de forme, soutien orthopédique pour un repos optimal.",
        "price": 49.90,
        "currency": "EUR",
        "stock": 18,
        "category": "NICHE_COUCHAGE",
        "photoUrl": ProductAssets.couchageOriginal,
        "active": true
      },
      {
        "name": "Panier Design Scandinave",
        "description": "Panier en feutre écologique aux lignes épurées, structure auto-portante et fond déhoussable lavable en machine.",
        "price": 59.00,
        "currency": "EUR",
        "stock": 14,
        "category": "NICHE_COUCHAGE",
        "photoUrl": ProductAssets.couchageIstock1125,
        "active": true
      },
      {
        "name": "Lit Surélevé Respirant",
        "description": "Structure en aluminium léger avec toile mesh respirante, idéal pour l'été et les animaux souffrant d'arthrose.",
        "price": 44.50,
        "currency": "EUR",
        "stock": 10,
        "category": "NICHE_COUCHAGE",
        "photoUrl": ProductAssets.couchageIstock1736,
        "active": true
      },
      {
        "name": "Maisonnette Chat Cocooning",
        "description": "Cabane fermée en peluche douce avec ouverture arrondie, refuge idéal pour les siestes et moments de tranquillité.",
        "price": 39.90,
        "currency": "EUR",
        "stock": 22,
        "category": "NICHE_COUCHAGE",
        "photoUrl": ProductAssets.couchage61peyr,
        "active": true
      },
      {
        "name": "Matelas Orthopédique Grande Taille",
        "description": "Matelas XL en mousse haute densité avec housse imperméable et antidérapante, conçu pour les grandes races.",
        "price": 79.00,
        "currency": "EUR",
        "stock": 8,
        "category": "NICHE_COUCHAGE",
        "photoUrl": ProductAssets.couchage71kU,
        "active": true
      },

      // ───────── HYGIÈNE & SOINS (5 produits) ─────────
      {
        "name": "Shampoing Doux & Lingettes Soin",
        "description": "Formule hypoallergénique aux extraits d'aloe vera et d'avoine bio, pour un pelage soyeux et une peau apaisée.",
        "price": 19.90,
        "currency": "EUR",
        "stock": 30,
        "category": "HYGIENE_SOINS",
        "photoUrl": ProductAssets.hygieneShampooings,
        "active": true
      },
      {
        "name": "Brosse Démêlante Ergonomique",
        "description": "Brosse à picots souples en acier inoxydable avec manche antidérapant, retire les nœuds sans tirer le poil.",
        "price": 16.50,
        "currency": "EUR",
        "stock": 40,
        "category": "HYGIENE_SOINS",
        "photoUrl": ProductAssets.hygieneCh7020,
        "active": true
      },
      {
        "name": "Spray Nettoyant Oreilles",
        "description": "Solution auriculaire douce à la camomille et calendula, prévient les infections et dissout le cérumen en douceur.",
        "price": 12.90,
        "currency": "EUR",
        "stock": 50,
        "category": "HYGIENE_SOINS",
        "photoUrl": ProductAssets.hygieneImages,
        "active": true
      },
      {
        "name": "Kit Coupe-Griffes Professionnel",
        "description": "Coupe-griffes en acier chirurgical avec butée de sécurité et lime intégrée, adapté à toutes les tailles d'animaux.",
        "price": 14.90,
        "currency": "EUR",
        "stock": 35,
        "category": "HYGIENE_SOINS",
        "photoUrl": ProductAssets.hygieneImages1,
        "active": true
      },
      {
        "name": "Dentifrice Enzymatique Menthe",
        "description": "Gel dentaire sans rinçage aux enzymes actives et menthe fraîche, prévient le tartre et les maladies parodontales.",
        "price": 11.50,
        "currency": "EUR",
        "stock": 45,
        "category": "HYGIENE_SOINS",
        "photoUrl": ProductAssets.hygieneImages2,
        "active": true
      },

      // ───────── ACCESSOIRES (5 produits) ─────────
      {
        "name": "Ensemble Laisse Cuir & Harnais Réfléchissant",
        "description": "Surpiqûres sellier, mousqueton en laiton brossé et inserts réfléchissants pour des promenades sûres et élégantes.",
        "price": 28.50,
        "currency": "EUR",
        "stock": 25,
        "category": "ACCESSORIES",
        "photoUrl": ProductAssets.accessoiresCollierLaisse,
        "active": true
      },
      {
        "name": "Gamelle Double Inox Anti-Dérapante",
        "description": "Double gamelle en acier inoxydable alimentaire sur support antidérapant en silicone, eau et nourriture séparées.",
        "price": 22.90,
        "currency": "EUR",
        "stock": 30,
        "category": "ACCESSORIES",
        "photoUrl": ProductAssets.accessoires715554235,
        "active": true
      },
      {
        "name": "Médaille Gravée Personnalisable",
        "description": "Médaille en alliage poli brillant, gravure laser recto-verso offerte, anneau renforcé anti-perte pour collier.",
        "price": 9.90,
        "currency": "EUR",
        "stock": 70,
        "category": "ACCESSORIES",
        "photoUrl": ProductAssets.accessoiresImages,
        "active": true
      },
      {
        "name": "Bandana Chic Coton Bio",
        "description": "Bandana artisanal en coton bio certifié, motifs exclusifs et attache réglable, parfait pour les sorties mode.",
        "price": 13.50,
        "currency": "EUR",
        "stock": 55,
        "category": "ACCESSORIES",
        "photoUrl": ProductAssets.accessoiresImages1,
        "active": true
      },
      {
        "name": "Fontaine à Eau Silencieuse 2L",
        "description": "Fontaine avec filtre charbon actif et pompe ultra-silencieuse, encourage l'hydratation grâce à l'eau en mouvement.",
        "price": 34.90,
        "currency": "EUR",
        "stock": 16,
        "category": "ACCESSORIES",
        "photoUrl": ProductAssets.accessoiresImages2,
        "active": true
      },

      // ───────── TRANSPORT (1 produit) ─────────
      {
        "name": "Sac de Voyage Confort Première Classe",
        "description": "Structure renforcée respirante avec ouverture panoramique et fond rembourré amovible pour des trajets sereins.",
        "price": 54.00,
        "currency": "EUR",
        "stock": 8,
        "category": "TRANSPORT",
        "photoUrl": ProductAssets.transportSac,
        "active": true
      },
    ];

    BuildContext? dialogContext;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        dialogContext = ctx;
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final api = ref.read(marketplaceApiProvider);

      // ── Prévention des doublons : récupérer les produits existants ──
      final existingProducts = await api.list();
      final existingNames = existingProducts.map((p) => p.name.toLowerCase()).toSet();

      final newProducts = fakeProducts.where(
        (p) => !existingNames.contains((p['name'] as String).toLowerCase()),
      ).toList();

      if (newProducts.isEmpty) {
        if (dialogContext != null && dialogContext!.mounted && Navigator.canPop(dialogContext!)) {
          Navigator.of(dialogContext!).pop();
        }
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('✅ Les produits sont déjà dans le catalogue.'),
            backgroundColor: Color(0xFF1F7A46),
          ),
        );
        return;
      }

      for (var product in newProducts) {
        await api.createProduct(product);
      }

      if (dialogContext != null && dialogContext!.mounted && Navigator.canPop(dialogContext!)) {
        Navigator.of(dialogContext!).pop();
      }

      ref.invalidate(productsProvider);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('✨ Catalogue enrichi avec les produits de luxe locaux !'),
          backgroundColor: Color(0xFF1F7A46),
        ),
      );
    } catch (e) {
      if (dialogContext != null && dialogContext!.mounted && Navigator.canPop(dialogContext!)) {
        Navigator.of(dialogContext!).pop();
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Erreur : $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final cartAsync = ref.watch(cartProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PET-CARE BOUTIQUE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Collection Exclusive',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined, color: Color(0xFF374151), size: 22),
            tooltip: 'Mes commandes',
            onPressed: () => context.push('/orders'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Badge(
                backgroundColor: theme.colorScheme.primary,
                label: Text(
                  '${cartAsync.value?.itemCount ?? 0}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                ),
                isLabelVisible: (cartAsync.value?.itemCount ?? 0) > 0,
                child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF374151), size: 23),
              ),
              onPressed: () => context.push('/cart'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _injectMagicProducts(context),
        backgroundColor: const Color(0xFF1F7A46),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.auto_fix_high, size: 18),
        label: const Text(
          'Injecter les Produits',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: -0.1),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // ─── Sélecteur horizontal de catégories épuré ───
          CategorySelector(
            selectedCategoryId: selectedCategory,
            onCategorySelected: (id) =>
                ref.read(selectedCategoryProvider.notifier).state = id,
          ),
          const SizedBox(height: 12),

          // ─── Catalogue de produits ───
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              error: (err, stack) {
                final isAuthError = err is DioException &&
                    (err.response?.statusCode == 401 || err.response?.statusCode == 403);

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isAuthError ? Icons.lock_outline_rounded : Icons.cloud_off_rounded,
                          size: 56,
                          color: const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isAuthError ? 'Connexion requise' : 'Catalogue momentanément indisponible',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isAuthError
                              ? 'Connectez-vous pour accéder aux produits et à vos avantages.'
                              : 'Vérifiez la connexion au serveur et réessayez.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        if (isAuthError)
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            onPressed: () => context.go('/login'),
                            icon: const Icon(Icons.login_rounded, size: 18),
                            label: const Text('Se connecter'),
                          )
                        else
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            onPressed: () => ref.invalidate(productsProvider),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Réessayer'),
                          ),
                      ],
                    ),
                  ),
                );
              },
              data: (products) {
                // ── Suppression des doublons par ID ──
                final seen = <String>{};
                final uniqueProducts = products.where((p) => seen.add(p.id)).toList();

                // Filtrage dynamique selon la catégorie sélectionnée
                final filteredProducts = selectedCategory == 'ALL'
                    ? uniqueProducts
                    : uniqueProducts.where((p) {
                        if (p.category == null) return false;
                        final cat = p.category!.toUpperCase();
                        return cat == selectedCategory ||
                            cat.contains(selectedCategory) ||
                            selectedCategory.contains(cat);
                      }).toList();

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          products.isEmpty
                              ? 'Aucun produit disponible.'
                              : 'Aucun produit dans cette sélection.',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Cliquez sur le bouton magique pour remplir la boutique.',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (_, i) => ProductCard(product: filteredProducts[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
