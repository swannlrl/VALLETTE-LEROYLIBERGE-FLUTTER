import 'package:flutter/material.dart';
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_vectorial_images.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

/// Onglet Nutrition : 4 blocs de niveaux nutritionnels avec couleurs
/// Repères : https://fr.openfoodfacts.org/reperes-nutritionnels
class ProductTab2 extends StatelessWidget {
  const ProductTab2({super.key});

  static const double _kHorizontalPadding = 20.0;

  @override
  Widget build(BuildContext context) {
    final Product product = context.watch<Product>();
    final nutrientLevels = product.nutrientLevels;

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _kHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.product_tab_nutrition,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.blue,
            ),
          ),
          const SizedBox(height: 16),

          // Matières grasses
          if (nutrientLevels.fat != null)
            _NutrientLevelCard(
              label: 'Matières grasses',
              level: nutrientLevels.fat!,
            ),

          // Acides gras saturés
          if (nutrientLevels.saturatedFat != null)
            _NutrientLevelCard(
              label: 'Acides gras saturés',
              level: nutrientLevels.saturatedFat!,
            ),

          // Sucres
          if (nutrientLevels.sugars != null)
            _NutrientLevelCard(
              label: 'Sucres',
              level: nutrientLevels.sugars!,
            ),

          // Sel
          if (nutrientLevels.salt != null)
            _NutrientLevelCard(
              label: 'Sel',
              level: nutrientLevels.salt!,
            ),
        ],
      ),
    );
  }
}

class _NutrientLevelCard extends StatelessWidget {
  const _NutrientLevelCard({
    required this.label,
    required this.level,
  });

  final String label;
  final String level;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String levelText;
    final String icon;

    switch (level.toLowerCase()) {
      case 'low':
        color = AppColors.nutrientLevelLow;
        levelText = 'Faible quantité';
        icon = AppVectorialImages.iconNutritionPie;
        break;
      case 'moderate':
        color = AppColors.nutrientLevelModerate;
        levelText = 'Quantité modérée';
        icon = AppVectorialImages.iconNutritionPie;
        break;
      case 'high':
        color = AppColors.nutrientLevelHigh;
        levelText = 'Quantité élevée';
        icon = AppVectorialImages.iconNutritionPie;
        break;
      default:
        color = AppColors.grey2;
        levelText = 'Non renseigné';
        icon = AppVectorialImages.iconNutritionPie;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            icon,
            width: 16,
            height: 16,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.blue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  levelText,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
