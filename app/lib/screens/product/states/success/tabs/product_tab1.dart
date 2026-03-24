import 'package:flutter/material.dart';
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_vectorial_images.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

/// Onglet Caractéristiques : Ingrédients, Allergènes, Additifs
class ProductTab1 extends StatelessWidget {
  const ProductTab1({super.key});

  static const double _kHorizontalPadding = 20.0;

  @override
  Widget build(BuildContext context) {
    final Product product = context.watch<Product>();
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _kHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ingrédients ──
          if (product.ingredients != null && product.ingredients!.isNotEmpty) ...[
            _SectionTitle(
              title: localizations.product_tab_properties,
              icon: AppVectorialImages.iconLocation,
            ),
            const SizedBox(height: 8),
            ...product.ingredients!.map(
              (ingredient) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  ingredient,
                  style: const TextStyle(fontSize: 15, color: AppColors.blue),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Allergènes ──
          if (product.allergens != null && product.allergens!.isNotEmpty) ...[
            const _SectionTitle(title: 'Allergènes'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.allergens!
                  .map(
                    (allergen) => Chip(
                      label: Text(
                        allergen,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      backgroundColor: Colors.red[400],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],

          // ── Traces éventuelles ──
          if (product.traces != null && product.traces!.isNotEmpty) ...[
            const _SectionTitle(
              title: 'Traces éventuelles',
              icon: AppVectorialImages.iconStarOrange,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.traces!
                  .map(
                    (trace) => Chip(
                      label: Text(
                        trace,
                        style: const TextStyle(fontSize: 13),
                      ),
                      backgroundColor: Colors.orange[100],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],

          // ── Additifs ──
          if (product.additives != null && product.additives!.isNotEmpty) ...[
            const _SectionTitle(title: 'Additifs'),
            const SizedBox(height: 8),
            ...product.additives!.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.blue,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: AppColors.grey3,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Si aucune donnée
          if ((product.ingredients == null || product.ingredients!.isEmpty) &&
              (product.allergens == null || product.allergens!.isEmpty) &&
              (product.additives == null || product.additives!.isEmpty))
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Aucune caractéristique disponible',
                  style: TextStyle(color: AppColors.grey2, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.icon});
  final String title;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          SvgPicture.asset(
            icon!,
            width: 18,
            height: 18,
            colorFilter: const ColorFilter.mode(AppColors.blue, BlendMode.srcIn),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.blue,
          ),
        ),
      ],
    );
  }
}
