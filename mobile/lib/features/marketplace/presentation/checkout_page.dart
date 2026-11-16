import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'cart_controller.dart';
import 'orders_controller.dart';

/// Page de checkout haut de gamme avec sélection de mode de paiement simulé.
class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  // ── Palette luxe ──
  static const _champagne = Color(0xFFD4A574);
  static const _champagneLight = Color(0xFFF8F0E8);
  static const _dark = Color(0xFF111827);
  static const _muted = Color(0xFF6B7280);
  static const _bg = Color(0xFFFAFAFB);
  static const _border = Color(0xFFF0F1F3);
  static const _cardBg = Colors.white;
  static const _tvaTaux = 0.20;

  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _postalCodeCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // Paiement simulé
  int _paymentMethod = 0; // 0=carte, 1=mobile, 2=livraison
  final _cardNumberCtrl = TextEditingController();
  final _cardExpiryCtrl = TextEditingController();
  final _cardCvvCtrl = TextEditingController();

  bool _isLoading = false;
  int _currentStep = 0; // 0=adresse, 1=paiement, 2=confirmation

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _streetCtrl.dispose();
    _postalCodeCtrl.dispose();
    _cityCtrl.dispose();
    _phoneCtrl.dispose();
    _cardNumberCtrl.dispose();
    _cardExpiryCtrl.dispose();
    _cardCvvCtrl.dispose();
    super.dispose();
  }

  // ── Calculs ──
  double get _subtotal {
    final cart = ref.read(cartProvider).value;
    return cart?.totalPrice ?? 0.0;
  }

  double get _tva => _subtotal * _tvaTaux;
  double get _shipping => _subtotal > 50 ? 0.0 : 5.99;
  double get _total => _subtotal + _tva + _shipping;
  String get _currency {
    final cart = ref.read(cartProvider).value;
    return cart?.currency ?? 'EUR';
  }

  int get _itemCount {
    final cart = ref.read(cartProvider).value;
    return cart?.itemCount ?? 0;
  }

  // ── Soumission ──
  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      // Aller à l'étape en erreur
      setState(() => _currentStep = 0);
      return;
    }

    final cart = ref.read(cartProvider).value;
    if (cart == null || cart.items.isEmpty) {
      _showSnack('Votre panier est vide.', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    final addressFormatted =
        '${_fullNameCtrl.text.trim()}, ${_streetCtrl.text.trim()}, '
        '${_postalCodeCtrl.text.trim()} ${_cityCtrl.text.trim()} '
        '(Tél: ${_phoneCtrl.text.trim()})';

    final paymentLabel = ['Carte bancaire', 'Apple Pay / Google Pay', 'Paiement à la livraison'][_paymentMethod];

    final payload = {
      'shippingAddress': addressFormatted,
      'fullName': _fullNameCtrl.text.trim(),
      'street': _streetCtrl.text.trim(),
      'postalCode': _postalCodeCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'paymentMethod': paymentLabel,
      'items': cart.items
          .map((item) => {
                'productId': item.product.id,
                'quantity': item.quantity,
                'unitPrice': item.product.price,
              })
          .toList(),
      'subtotal': _subtotal,
      'tax': _tva,
      'shippingFee': _shipping,
      'totalAmount': _total,
      'currency': _currency,
    };

    try {
      final order = await ref.read(ordersProvider.notifier).placeOrder(payload);
      await ref.read(cartProvider.notifier).clear();

      if (mounted) {
        context.go('/order-success', extra: {
          'orderRef': order.id,
          'totalAmount': _total,
          'itemCount': _itemCount,
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Erreur lors de la validation : $e', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Décoration des champs ──
  InputDecoration _luxeInput({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: _muted),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      labelStyle: const TextStyle(color: _muted, fontSize: 14),
      hintStyle: TextStyle(color: _muted.withAlpha(120), fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _champagne, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider).value;

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
          'CHECKOUT',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: _dark,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // ── Stepper visuel ──
            _buildStepIndicator(),

            // ── Contenu scrollable ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Étape 1 : Adresse
                    if (_currentStep == 0) _buildAddressSection(),

                    // Étape 2 : Paiement
                    if (_currentStep == 1) _buildPaymentSection(),

                    // Étape 3 : Récapitulatif
                    if (_currentStep == 2)
                      _buildSummarySection(cart),
                  ],
                ),
              ),
            ),

            // ── Barre de prix + CTA ──
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // STEPPER VISUEL
  // ═══════════════════════════════════════════════════════════
  Widget _buildStepIndicator() {
    const labels = ['Adresse', 'Paiement', 'Confirmer'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: GestureDetector(
              onTap: isDone ? () => setState(() => _currentStep = i) : null,
              child: Column(
                children: [
                  Row(
                    children: [
                      if (i > 0)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: isDone || isActive
                                ? _champagne
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone
                              ? _champagne
                              : isActive
                                  ? _champagne
                                  : const Color(0xFFE5E7EB),
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(Icons.check_rounded,
                                  size: 16, color: Colors.white)
                              : Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isActive
                                        ? Colors.white
                                        : _muted,
                                  ),
                                ),
                        ),
                      ),
                      if (i < 2)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: isDone
                                ? _champagne
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive || isDone ? _dark : _muted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SECTION 1 : ADRESSE
  // ═══════════════════════════════════════════════════════════
  Widget _buildAddressSection() {
    return _LuxeCard(
      title: 'Adresse de livraison',
      icon: Icons.location_on_outlined,
      child: Column(
        children: [
          TextFormField(
            controller: _fullNameCtrl,
            decoration: _luxeInput(
              label: 'Nom complet',
              icon: Icons.person_outline_rounded,
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Nom requis' : null,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _streetCtrl,
            decoration: _luxeInput(
              label: 'Adresse postale',
              icon: Icons.home_outlined,
              hint: '12 Rue de la Paix',
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Adresse requise' : null,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _postalCodeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _luxeInput(
                    label: 'Code postal',
                    icon: Icons.markunread_mailbox_outlined,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Requis' : null,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _cityCtrl,
                  decoration: _luxeInput(
                    label: 'Ville',
                    icon: Icons.location_city_outlined,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Requis' : null,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: _luxeInput(
              label: 'Téléphone',
              icon: Icons.phone_outlined,
              hint: '+33 6 12 34 56 78',
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Numéro requis' : null,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SECTION 2 : PAIEMENT
  // ═══════════════════════════════════════════════════════════
  Widget _buildPaymentSection() {
    return Column(
      children: [
        _LuxeCard(
          title: 'Mode de paiement',
          icon: Icons.payment_outlined,
          child: Column(
            children: [
              _PaymentOption(
                index: 0,
                selected: _paymentMethod == 0,
                icon: Icons.credit_card_rounded,
                title: 'Carte bancaire',
                subtitle: 'Visa, Mastercard, CB',
                onTap: () => setState(() => _paymentMethod = 0),
              ),
              const SizedBox(height: 10),
              _PaymentOption(
                index: 1,
                selected: _paymentMethod == 1,
                icon: Icons.phone_iphone_rounded,
                title: 'Apple Pay / Google Pay',
                subtitle: 'Paiement rapide en un tap',
                onTap: () => setState(() => _paymentMethod = 1),
              ),
              const SizedBox(height: 10),
              _PaymentOption(
                index: 2,
                selected: _paymentMethod == 2,
                icon: Icons.local_shipping_outlined,
                title: 'Paiement à la livraison',
                subtitle: 'Payez à réception de votre colis',
                onTap: () => setState(() => _paymentMethod = 2),
              ),
            ],
          ),
        ),

        // Champs carte si mode carte sélectionné
        if (_paymentMethod == 0) ...[
          const SizedBox(height: 8),
          _LuxeCard(
            title: 'Informations de la carte',
            icon: Icons.lock_outline_rounded,
            child: Column(
              children: [
                TextFormField(
                  controller: _cardNumberCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _CardNumberFormatter(),
                    LengthLimitingTextInputFormatter(19),
                  ],
                  decoration: _luxeInput(
                    label: 'Numéro de carte',
                    icon: Icons.credit_card_rounded,
                    hint: '4242 4242 4242 4242',
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cardExpiryCtrl,
                        keyboardType: TextInputType.datetime,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _ExpiryFormatter(),
                          LengthLimitingTextInputFormatter(5),
                        ],
                        decoration: _luxeInput(
                          label: 'Expiration',
                          icon: Icons.calendar_today_outlined,
                          hint: 'MM/AA',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _cardCvvCtrl,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: _luxeInput(
                          label: 'CVV',
                          icon: Icons.security_rounded,
                          hint: '•••',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _champagneLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined,
                          size: 16, color: _champagne),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Paiement sécurisé — Environnement de démonstration',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: _champagne,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        if (_paymentMethod == 1) ...[
          const SizedBox(height: 8),
          _LuxeCard(
            title: '',
            icon: Icons.phone_iphone_rounded,
            showHeader: false,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _champagneLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.phone_iphone_rounded,
                        size: 32, color: _champagne),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Paiement mobile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _dark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Un prompt de validation apparaîtra\nlors de la confirmation.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: _muted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SECTION 3 : RÉCAPITULATIF
  // ═══════════════════════════════════════════════════════════
  Widget _buildSummarySection(dynamic cart) {
    final paymentLabels = [
      'Carte bancaire',
      'Apple Pay / Google Pay',
      'Paiement à la livraison',
    ];
    final paymentIcons = [
      Icons.credit_card_rounded,
      Icons.phone_iphone_rounded,
      Icons.local_shipping_outlined,
    ];

    return Column(
      children: [
        // Adresse
        _LuxeCard(
          title: 'Livraison',
          icon: Icons.location_on_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _fullNameCtrl.text,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: _dark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_streetCtrl.text}\n${_postalCodeCtrl.text} ${_cityCtrl.text}',
                style: TextStyle(fontSize: 14, color: _muted, height: 1.4),
              ),
              const SizedBox(height: 4),
              Text(
                _phoneCtrl.text,
                style: TextStyle(fontSize: 14, color: _muted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Paiement
        _LuxeCard(
          title: 'Paiement',
          icon: paymentIcons[_paymentMethod],
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _champagneLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(paymentIcons[_paymentMethod],
                    size: 22, color: _champagne),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paymentLabels[_paymentMethod],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _dark,
                      ),
                    ),
                    if (_paymentMethod == 0 &&
                        _cardNumberCtrl.text.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '•••• ${_cardNumberCtrl.text.replaceAll(' ', '').padLeft(4).substring(_cardNumberCtrl.text.replaceAll(' ', '').length > 4 ? _cardNumberCtrl.text.replaceAll(' ', '').length - 4 : 0)}',
                        style: TextStyle(fontSize: 13, color: _muted),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Détail prix
        _LuxeCard(
          title: 'Détail de la commande',
          icon: Icons.receipt_long_outlined,
          child: Column(
            children: [
              // Articles
              if (cart != null)
                ...cart.items.map<Widget>((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: _champagne,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${item.quantity}× ${item.product.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14, color: _dark),
                            ),
                          ),
                          Text(
                            '${item.totalPrice.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _dark,
                            ),
                          ),
                        ],
                      ),
                    )),

              const Divider(color: _border, height: 24),

              _PriceRow(label: 'Sous-total', value: _subtotal),
              const SizedBox(height: 6),
              _PriceRow(label: 'TVA (20%)', value: _tva),
              const SizedBox(height: 6),
              _PriceRow(
                label: 'Livraison',
                value: _shipping,
                isFree: _shipping == 0,
              ),
              const Divider(color: _border, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _dark,
                    ),
                  ),
                  Text(
                    '${_total.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: _champagne,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BARRE DU BAS
  // ═══════════════════════════════════════════════════════════
  Widget _buildBottomBar() {
    final isLast = _currentStep == 2;
    final buttonLabel = isLast
        ? 'Confirmer et Payer'
        : _currentStep == 0
            ? 'Continuer vers le paiement'
            : 'Vérifier la commande';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: _cardBg,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Prix total discret
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total TTC',
                  style: TextStyle(
                    fontSize: 14,
                    color: _muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${_total.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _dark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // CTA
            Row(
              children: [
                if (_currentStep > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () =>
                            setState(() => _currentStep--),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _dark,
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18),
                      ),
                    ),
                  ),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (isLast) {
                                _submitOrder();
                              } else {
                                // Valider le formulaire avant de passer à l'étape 1
                                if (_currentStep == 0) {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }
                                }
                                setState(() => _currentStep++);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _dark,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _dark.withAlpha(150),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isLast)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Icon(Icons.lock_rounded, size: 18),
                                  ),
                                Text(
                                  buttonLabel,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                if (!isLast)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 6),
                                    child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14),
                                  ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// WIDGETS RÉUTILISABLES
// ═════════════════════════════════════════════════════════════

/// Carte luxe réutilisable.
class _LuxeCard extends StatelessWidget {
  const _LuxeCard({
    required this.title,
    required this.icon,
    required this.child,
    this.showHeader = true,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F1F3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader && title.isNotEmpty) ...[
            Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFFD4A574)),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
          ],
          child,
        ],
      ),
    );
  }
}

/// Option de paiement sélectionnable.
class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.index,
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final int index;
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFF8F0E8)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFFD4A574)
                : const Color(0xFFF0F1F3),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected ? Colors.white : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 22,
                  color: selected
                      ? const Color(0xFFD4A574)
                      : const Color(0xFF6B7280)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: selected
                          ? const Color(0xFF111827)
                          : const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? const Color(0xFFD4A574)
                      : const Color(0xFFD1D5DB),
                  width: selected ? 6 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ligne de prix formatée.
class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.isFree = false,
  });

  final String label;
  final double value;
  final bool isFree;

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
          isFree ? 'Gratuite' : '${value.toStringAsFixed(2)} €',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isFree
                ? const Color(0xFF059669)
                : const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════
// FORMATTERS CARTES BANCAIRES
// ═════════════════════════════════════════════════════════════

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
