import 'package:flutter/material.dart';
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProductTab3 extends StatelessWidget {
  const ProductTab3({super.key});

  static const double _kHorizontalPadding = 20.0;

  @override
  Widget build(BuildContext context) {
    final Product product = context.watch<Product>();
    if (product.nutritionFacts == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Aucune valeur nutritionnelle disponible',
            style: TextStyle(color: AppColors.grey2, fontSize: 16),
          ),
        ),
      );
    }

    final localizations = AppLocalizations.of(context)!;
    final facts = product.nutritionFacts!;
    final numberFormat = NumberFormat.decimalPatternDigits(
      locale: 'fr',
      decimalDigits: 2,
    );

    String fmt(dynamic val, String unit) {
      if (val == null) return '?';
      if (val is num) return '${numberFormat.format(val)} $unit';
      return '$val $unit';
    }

    final rows = <_TableRow>[
      _TableRow(
        label: localizations.product_nutrition_facts_energy,
        per100g: fmt(facts.energy?.per100g, facts.energy?.unit ?? 'kJ'),
        perServing: fmt(facts.energy?.perServing, facts.energy?.unit ?? 'kJ'),
        isSubItem: false,
      ),
      _TableRow(
        label: localizations.product_nutrition_facts_fat,
        per100g: fmt(facts.fat?.per100g, facts.fat?.unit ?? 'g'),
        perServing: fmt(facts.fat?.perServing, facts.fat?.unit ?? 'g'),
        isSubItem: false,
      ),
      _TableRow(
        label: localizations.product_nutrition_facts_saturated_fats,
        per100g: fmt(facts.saturatedFat?.per100g, facts.saturatedFat?.unit ?? 'g'),
        perServing: fmt(facts.saturatedFat?.perServing, facts.saturatedFat?.unit ?? 'g'),
        isSubItem: true,
      ),
      _TableRow(
        label: localizations.product_nutrition_facts_carbohydrates,
        per100g: fmt(facts.carbohydrate?.per100g, facts.carbohydrate?.unit ?? 'g'),
        perServing: fmt(facts.carbohydrate?.perServing, facts.carbohydrate?.unit ?? 'g'),
        isSubItem: false,
      ),
      _TableRow(
        label: localizations.product_nutrition_facts_sugars,
        per100g: fmt(facts.sugar?.per100g, facts.sugar?.unit ?? 'g'),
        perServing: fmt(facts.sugar?.perServing, facts.sugar?.unit ?? 'g'),
        isSubItem: true,
      ),
      _TableRow(
        label: localizations.product_nutrition_facts_fiber,
        per100g: fmt(facts.fiber?.per100g, facts.fiber?.unit ?? 'g'),
        perServing: fmt(facts.fiber?.perServing, facts.fiber?.unit ?? 'g'),
        isSubItem: false,
      ),
      _TableRow(
        label: localizations.product_nutrition_facts_proteins,
        per100g: fmt(facts.proteins?.per100g, facts.proteins?.unit ?? 'g'),
        perServing: fmt(facts.proteins?.perServing, facts.proteins?.unit ?? 'g'),
        isSubItem: false,
      ),
      _TableRow(
        label: localizations.product_nutrition_facts_salt,
        per100g: fmt(facts.salt?.per100g, facts.salt?.unit ?? 'g'),
        perServing: fmt(facts.salt?.perServing, facts.salt?.unit ?? 'g'),
        isSubItem: false,
      ),
      _TableRow(
        label: localizations.product_nutrition_facts_sodium,
        per100g: fmt(facts.sodium?.per100g, facts.sodium?.unit ?? 'g'),
        perServing: fmt(facts.sodium?.perServing, facts.sodium?.unit ?? 'g'),
        isSubItem: false,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _kHorizontalPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              children: [
                const Expanded(flex: 5, child: SizedBox.shrink()),
                Expanded(
                  flex: 3,
                  child: Text(
                    localizations.product_nutrition_facts_per_100g,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    localizations.product_nutrition_facts_per_serving,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.grey1),
          ...rows.map((row) => _NutritionTableRow(row: row)),
        ],
      ),
    );
  }
}

class _TableRow {
  final String label;
  final String per100g;
  final String perServing;
  final bool isSubItem;

  const _TableRow({
    required this.label,
    required this.per100g,
    required this.perServing,
    required this.isSubItem,
  });
}

class _NutritionTableRow extends StatelessWidget {
  const _NutritionTableRow({required this.row});

  final _TableRow row;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 10,
            bottom: 10,
            left: row.isSubItem ? 16.0 : 0.0,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  row.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.blue,
                    fontWeight: row.isSubItem ? FontWeight.w400 : FontWeight.w500,
                    fontStyle: row.isSubItem ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  row.per100g,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.blue,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  row.perServing,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.grey3,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.grey1),
      ],
    );
  }
}
