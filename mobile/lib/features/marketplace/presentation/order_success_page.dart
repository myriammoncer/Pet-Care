import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Écran de confirmation de commande — design haut de gamme.
class OrderSuccessPage extends StatefulWidget {
  const OrderSuccessPage({
    super.key,
    this.orderRef,
    this.totalAmount,
    this.itemCount,
  });

  final String? orderRef;
  final double? totalAmount;
  final int? itemCount;

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage>
    with TickerProviderStateMixin {
  // ── Couleurs luxe ──
  static const _champagne = Color(0xFFD4A574);
  static const _champagneLight = Color(0xFFF8F0E8);
  static const _dark = Color(0xFF111827);
  static const _muted = Color(0xFF6B7280);
  static const _bg = Color(0xFFFAFAFB);
  static const _success = Color(0xFF059669);

  late final AnimationController _checkController;
  late final AnimationController _contentController;
  late final Animation<double> _checkScale;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    // ── Animation du check ──
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );

    // ── Animation du contenu ──
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(_contentFade);

    // Séquence : check d'abord, puis contenu
    _checkController.forward().then((_) {
      _contentController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String get _orderReference =>
      widget.orderRef ?? 'PC-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // ── Icône de succès animée ──
                ScaleTransition(
                  scale: _checkScale,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _success.withAlpha(60),
                          blurRadius: 32,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 56,
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // ── Contenu animé ──
                SlideTransition(
                  position: _contentSlide,
                  child: FadeTransition(
                    opacity: _contentFade,
                    child: Column(
                      children: [
                        // Titre
                        const Text(
                          'Commande Confirmée',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Merci pour votre confiance.\nVotre commande est en cours de préparation.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: _muted,
                            height: 1.55,
                          ),
                        ),

                        const SizedBox(height: 36),

                        // ── Carte récapitulatif ──
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFF0F1F3)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x08000000),
                                blurRadius: 24,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Référence
                              _SummaryRow(
                                icon: Icons.receipt_long_outlined,
                                label: 'Référence',
                                value: _orderReference,
                                valueColor: _champagne,
                              ),
                              const _SummaryDivider(),

                              // Statut
                              const _SummaryRow(
                                icon: Icons.local_shipping_outlined,
                                label: 'Statut',
                                value: 'En préparation',
                                valueColor: _success,
                              ),
                              const _SummaryDivider(),

                              // Articles
                              if (widget.itemCount != null) ...[
                                _SummaryRow(
                                  icon: Icons.shopping_bag_outlined,
                                  label: 'Articles',
                                  value:
                                      '${widget.itemCount} article${(widget.itemCount ?? 0) > 1 ? 's' : ''}',
                                ),
                                const _SummaryDivider(),
                              ],

                              // Livraison
                              const _SummaryRow(
                                icon: Icons.schedule_outlined,
                                label: 'Livraison estimée',
                                value: '3–5 jours ouvrés',
                              ),

                              if (widget.totalAmount != null) ...[
                                const _SummaryDivider(),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total payé',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: _dark,
                                      ),
                                    ),
                                    Text(
                                      '${widget.totalAmount!.toStringAsFixed(2)} €',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: _champagne,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Badge de sécurité ──
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: _champagneLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_outlined,
                                  size: 18, color: _champagne),
                              const SizedBox(width: 8),
                              const Text(
                                'Paiement sécurisé & garanti',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _champagne,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 44),

                        // ── Boutons ──
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: () => context.go('/orders'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _dark,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.list_alt_rounded, size: 20),
                            label: const Text(
                              'Voir mes commandes',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton.icon(
                            onPressed: () => context.go('/marketplace'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _dark,
                              side: const BorderSide(color: Color(0xFFE5E7EB)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.storefront_outlined,
                                size: 20),
                            label: const Text(
                              'Retourner à la boutique',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Widgets internes
// ─────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Divider(color: Color(0xFFF3F4F6), height: 1),
    );
  }
}

