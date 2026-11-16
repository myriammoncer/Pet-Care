import 'package:flutter/material.dart';
import '../../domain/category.dart';

/// Sélecteur horizontal de catégories épuré et haut de gamme
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: Category.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = Category.categories[index];
          final isSelected = selectedCategoryId == category.id;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: Material(
              color: isSelected ? primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => onCategorySelected(category.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? primaryColor
                          : const Color(0xFFE8ECEF),
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category.icon,
                        size: 16,
                        color: isSelected ? Colors.white : const Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF374151),
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
