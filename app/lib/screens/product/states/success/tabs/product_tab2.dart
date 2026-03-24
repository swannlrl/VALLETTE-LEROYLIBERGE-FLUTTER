import 'package:flutter/material.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Onglet Nutrition : repères nutritionnels par 100g avec niveaux et valeurs
class ProductTab2 extends StatelessWidget {
  const ProductTab2({super.key});

  static const double _kHorizontalPadding = 20.0;

  @override
  Widget build(BuildContext context) {
    final Product product = context.watch<Product>();
    final nutrientLevels = product.nutrientLevels;
    final nutritionFacts = product.nutritionFacts;

    if (nutrientLevels == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Aucune donnée nutritionnelle disponible',
            style: TextStyle(color: AppColors.grey2, fontSize: 16),
          ),
        ),
      );
    }

    final numberFormat = NumberFormat.decimalPatternDigits(
      locale: 'fr',
      decimalDigits: 2,
    );

    String formatVal(Nutriment? n) {
      if (n?.per100g == null) return '';
      final v = n!.per100g;
      if (v is num) {
        // remove trailing zeros: 0.10 → 0,1
        final formatted = numberFormat.format(v);
        return '$formatted ${n.unit}';
      }
      return '$v ${n.unit}';
    }

    final rows = <_NutrientEntry>[
      _NutrientEntry(
        label: 'Matières grasses / lipides',
        level: nutrientLevels.fat,
        value: formatVal(nutritionFacts?.fat),
      ),
      _NutrientEntry(
        label: 'Acides gras saturés',
        level: nutrientLevels.saturatedFat,
        value: formatVal(nutritionFacts?.saturatedFat),
      ),
      _NutrientEntry(
        label: 'Sucres',
        level: nutrientLevels.sugars,
        value: formatVal(nutritionFacts?.sugar),
      ),
      _NutrientEntry(
        label: 'Sel',
        level: nutrientLevels.salt,
        value: formatVal(nutritionFacts?.salt),
      ),
    ].where((e) => e.level != null).toList();

    if (rows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Aucune donnée nutritionnelle disponible',
            style: TextStyle(color: AppColors.grey2, fontSize: 16),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _kHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Repères nutritionnels pour 100g',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.grey3,
              fontSize: 13,
              fontFamily: 'Avenir',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.blue, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < rows.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.grey1,
                      indent: 0,
                      endIndent: 0,
                    ),
                  _NutrientRow(entry: rows[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NutrientEntry {
  final String label;
  final String? level;
  final String value;

  const _NutrientEntry({
    required this.label,
    required this.level,
    required this.value,
  });
}

class _NutrientRow extends StatelessWidget {
  const _NutrientRow({required this.entry});

  final _NutrientEntry entry;

  @override
  Widget build(BuildContext context) {
    final Color levelColor;
    final String levelText;

    switch (entry.level?.toLowerCase()) {
      case 'low':
        levelColor = AppColors.nutrientLevelLow;
        levelText = 'Faible quantité';
        break;
      case 'moderate':
        levelColor = AppColors.nutrientLevelModerate;
        levelText = 'Quantité modérée';
        break;
      case 'high':
        levelColor = AppColors.nutrientLevelHigh;
        levelText = 'Quantité élevée';
        break;
      default:
        levelColor = AppColors.grey2;
        levelText = 'Non renseigné';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              entry.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.blue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (entry.value.isNotEmpty)
                Text(
                  entry.value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.blue,
                  ),
                ),
              Text(
                levelText,
                style: TextStyle(
                  fontSize: 12,
                  color: levelColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
