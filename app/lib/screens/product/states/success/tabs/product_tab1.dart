import 'package:flutter/material.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:provider/provider.dart';

/// Onglet Caractéristiques : Ingrédients, Allergènes, Additifs
class ProductTab1 extends StatelessWidget {
  const ProductTab1({super.key});

  static const double _kHorizontalPadding = 28.0; // From Sketch: 28px right margin

  @override
  Widget build(BuildContext context) {
    final Product product = context.watch<Product>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8.0),
        // ── Ingrédients ──
        const _SectionDividerTitle(title: 'Ingrédients'),
        if (product.ingredients != null && product.ingredients!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _kHorizontalPadding),
            child: Column(
              children: product.ingredients!.map(
                (ingredient) => _IngredientRow(ingredient: ingredient),
              ).toList(),
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: _kHorizontalPadding, vertical: 16),
            child: _EmptyText(text: 'Aucun'),
          ),
        const SizedBox(height: 24),

        // ── Substances allergènes ──
        const _SectionDividerTitle(title: 'Substances allergènes'),
        if (product.allergens != null && product.allergens!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _kHorizontalPadding),
            child: Column(
              children: product.allergens!
                  .map((allergen) => _SimpleRow(text: _capitalize(allergen)))
                  .toList(),
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: _kHorizontalPadding, vertical: 16),
            child: _EmptyText(text: 'Aucune'),
          ),
        const SizedBox(height: 24),

        // ── Additifs ──
        const _SectionDividerTitle(title: 'Additifs'),
        if (product.additives != null && product.additives!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _kHorizontalPadding),
            child: Column(
              children: product.additives!.keys.map(
                (additive) => _SimpleRow(text: _capitalize(additive)),
              ).toList(),
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: _kHorizontalPadding, vertical: 16),
            child: _EmptyText(text: 'Aucun'),
          ),
        const SizedBox(height: 24),
      ],
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
    return Container(
      width: double.infinity,
      color: AppColors.grey1,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800, // Avenir-Black
          color: AppColors.blue,
          fontFamily: 'Avenir',
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Ingredient row: name (bold) | value (grey)
// ─────────────────────────────────────────────

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.ingredient});

  final Ingredient ingredient;

  @override
  Widget build(BuildContext context) {
    final String name = ingredient.displayName;
    final String? value = ingredient.subIngredientsText;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blue,
                    fontFamily: 'Avenir',
                  ),
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Text(
                    value,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey3,
                      fontFamily: 'Avenir',
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
// Simple text row with divider (allergens, additives)
// ─────────────────────────────────────────────

class _SimpleRow extends StatelessWidget {
  const _SimpleRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.blue,
                fontFamily: 'Avenir',
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.grey1),
      ],
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
        color: AppColors.blue,
        fontWeight: FontWeight.w600,
        fontFamily: 'Avenir',
        fontSize: 14,
      ),
    );
  }
}
