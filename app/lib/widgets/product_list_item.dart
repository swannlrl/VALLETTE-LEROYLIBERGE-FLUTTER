import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_vectorial_images.dart';

class ProductListItem extends StatelessWidget {
  final String barcode;
  final Product? product;
  final VoidCallback onTap;

  const ProductListItem({
    super.key,
    required this.barcode,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = product;
    final String title = p?.name ?? barcode;
    final String subtitle = (p?.brands != null && p!.brands!.isNotEmpty) ? p.brands!.first : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        height: 124,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 20,
              right: 0,
              top: 16,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.14),
                      offset: Offset(0, 5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                padding: const EdgeInsets.only(left: 96, top: 12, right: 16, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.blue,
                        fontFamily: 'Avenir',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.grey3,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    _NutriscoreBadge(score: p?.nutriScore),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.grey1,
                ),
                clipBehavior: Clip.hardEdge,
                child: p?.picture != null
                    ? CachedNetworkImage(
                        imageUrl: p!.picture!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.blue,
                          ),
                        ),
                        errorWidget: (context, url, error) => Padding(
                          padding: const EdgeInsets.all(24),
                          child: SvgPicture.asset(
                            AppVectorialImages.iconImagePlaceholderAlt,
                            colorFilter: const ColorFilter.mode(AppColors.grey2, BlendMode.srcIn),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(24),
                        child: SvgPicture.asset(
                          AppVectorialImages.iconImagePlaceholder,
                          colorFilter: const ColorFilter.mode(AppColors.grey2, BlendMode.srcIn),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutriscoreBadge extends StatelessWidget {
  final ProductNutriScore? score;

  const _NutriscoreBadge({this.score});

  @override
  Widget build(BuildContext context) {
    if (score == null) return const SizedBox.shrink();

    final label = switch (score) {
      ProductNutriScore.A => 'A',
      ProductNutriScore.B => 'B',
      ProductNutriScore.C => 'C',
      ProductNutriScore.D => 'D',
      ProductNutriScore.E => 'E',
      _ => null,
    };

    final color = switch (score) {
      ProductNutriScore.A => AppColors.nutriscoreA,
      ProductNutriScore.B => AppColors.nutriscoreB,
      ProductNutriScore.C => AppColors.nutriscoreC,
      ProductNutriScore.D => AppColors.nutriscoreD,
      ProductNutriScore.E => AppColors.nutriscoreE,
      _ => AppColors.grey2,
    };

    if (label == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Nutriscore : $label',
          style: const TextStyle(
            color: AppColors.blue,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
