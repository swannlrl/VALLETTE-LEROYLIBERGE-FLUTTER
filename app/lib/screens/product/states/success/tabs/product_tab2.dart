import 'package:flutter/material.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Onglet Nutrition : repères nutritionnels par 100g
class ProductTab2 extends StatelessWidget {
  const ProductTab2({super.key});

  @override
  Widget build(BuildContext context) {
    final Product product = context.watch<Product>();
    final nutrientLevels = product.nutrientLevels;
    final nutritionFacts = product.nutritionFacts;

    if (nutrientLevels == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Aucune donnée nutritionnelle disponible',
            style: TextStyle(color: AppColors.grey2, fontSize: 16),
          ),
        ),
      );
    }

    final fmt = NumberFormat('#.##', 'fr'); // Ex: 0,8g / 0,75g (sans zéros inutiles)

    String fmtVal(Nutriment? n) {
      if (n?.per100g == null) return '';
      final v = n!.per100g;
      return v is num ? '${fmt.format(v)}${n.unit}' : '$v${n.unit}';
    }

    final rows = <_NutrientEntry>[
      _NutrientEntry(
        label: 'Matières grasses / lipides',
        level: nutrientLevels.fat,
        value: fmtVal(nutritionFacts?.fat),
      ),
      _NutrientEntry(
        label: 'Acides gras saturés',
        level: nutrientLevels.saturatedFat,
        value: fmtVal(nutritionFacts?.saturatedFat),
      ),
      _NutrientEntry(
        label: 'Sucres',
        level: nutrientLevels.sugars,
        value: fmtVal(nutritionFacts?.sugar),
      ),
      _NutrientEntry(
        label: 'Sel',
        level: nutrientLevels.salt,
        value: fmtVal(nutritionFacts?.salt),
      ),
    ].where((e) => e.level != null).toList();

    if (rows.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Aucune donnée nutritionnelle disponible',
            style: TextStyle(color: AppColors.grey2, fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'Repères nutritionnels pour 100g',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.grey3,
              fontSize: 13,
              fontFamily: 'Avenir',
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.grey1),
        ...rows.map((entry) => _NutrientRow(entry: entry)),
      ],
    );
  }
}

class _NutrientEntry {
  final String label;
  final String? level;
  final String value;
  const _NutrientEntry({required this.label, required this.level, required this.value});
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(21, 14, 28, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                children: [
                  if (entry.value.isNotEmpty)
                    Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: levelColor,
                        fontFamily: 'Avenir',
                      ),
                    ),
                  Text(
                    levelText,
                    style: TextStyle(
                      fontSize: 15,
                      color: levelColor,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Avenir',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.grey1),
      ],
    );
  }
}
