import 'package:flutter/material.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:provider/provider.dart';

/// Onglet Caractéristiques : Ingrédients, Allergènes, Additifs
class ProductTab1 extends StatelessWidget {
  const ProductTab1({super.key});

  static const double _kHorizontalPadding = 20.0;

  @override
  Widget build(BuildContext context) {
    final Product product = context.watch<Product>();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _kHorizontalPadding,
        vertical: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ingrédients ──
          const _SectionDividerTitle(title: 'Ingrédients'),
          const SizedBox(height: 12),
          if (product.ingredients != null && product.ingredients!.isNotEmpty)
            ...product.ingredients!.map(
              (ingredient) => _IngredientRow(text: ingredient),
            )
          else
            const _EmptyText(text: 'Aucun'),
          const SizedBox(height: 24),

          // ── Substances allergènes ──
          const _SectionDividerTitle(title: 'Substances allergènes'),
          const SizedBox(height: 12),
          if (product.allergens != null && product.allergens!.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: product.allergens!
                  .map(
                    (allergen) => _AllergenChip(label: _capitalize(allergen)),
                  )
                  .toList(),
            )
          else
            const _EmptyText(text: 'Aucune'),
          const SizedBox(height: 24),

          // ── Additifs ──
          const _SectionDividerTitle(title: 'Additifs'),
          const SizedBox(height: 12),
          if (product.additives != null && product.additives!.isNotEmpty)
            ...product.additives!.keys.map(
              (additive) => _IngredientRow(text: _capitalize(additive)),
            )
          else
            const _EmptyText(text: 'Aucun'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

// ─────────────────────────────────────────────
// Section header: ────── Titre ──────
// ─────────────────────────────────────────────

class _SectionDividerTitle extends StatelessWidget {
  const _SectionDividerTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: AppColors.blue,
            thickness: 1,
            endIndent: 10,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.blue,
            fontFamily: 'Avenir',
          ),
        ),
        const Expanded(
          child: Divider(
            color: AppColors.blue,
            thickness: 1,
            indent: 10,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Ingredient row: name (bold) | value (grey)
// ─────────────────────────────────────────────

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    // Try to split "Légumes (41%)" → name="Légumes", value="41%"
    final parenMatch = RegExp(r'^(.*?)\s*\((.+)\)$').firstMatch(text);
    final String name =
        parenMatch != null ? parenMatch.group(1)!.trim() : text.trim();
    final String? value = parenMatch?.group(2)?.trim();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        value != null ? FontWeight.w600 : FontWeight.w400,
                    color: AppColors.blue,
                  ),
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.grey3,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.grey1),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Allergen chip
// ─────────────────────────────────────────────

class _AllergenChip extends StatelessWidget {
  const _AllergenChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFECEC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE05252), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFE05252),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// "Aucun / Aucune" placeholder
// ─────────────────────────────────────────────

class _EmptyText extends StatelessWidget {
  const _EmptyText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.grey2,
        fontSize: 14,
      ),
    );
  }
}
