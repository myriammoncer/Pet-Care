import 'package:flutter/material.dart';
import '../constants/product_assets.dart';

/// Composant d'image produit haut de gamme avec animation de fondu et gestion d'assets locaux
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.photoUrl,
    this.category,
    this.identifier,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.fallbackIconSize = 44,
    this.borderRadius,
  });

  final String? photoUrl;
  final String? category;
  final String? identifier;
  final BoxFit fit;
  final double? width;
  final double? height;
  final double fallbackIconSize;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final assetPath = ProductAssets.resolveAsset(photoUrl, category, identifier);

    Widget imageWidget = Image.asset(
      assetPath,
      fit: fit,
      width: width,
      height: height,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: const Color(0xFFF5F6F8),
          child: Center(
            child: Icon(
              Icons.pets_outlined,
              size: fallbackIconSize,
              color: const Color(0xFFCBD2D9),
            ),
          ),
        );
      },
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
