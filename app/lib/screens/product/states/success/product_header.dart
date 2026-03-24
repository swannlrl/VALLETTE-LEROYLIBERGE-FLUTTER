import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_vectorial_images.dart';
import 'package:formation_flutter/res/app_theme_extension.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

class ProductPageHeader extends StatelessWidget {
  const ProductPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      children: const <Widget>[ProductImageHeader(), ProductNameHeader()],
    );
  }
}

class ProductImageHeader extends StatelessWidget {
  const ProductImageHeader({super.key});

  static const double kImageHeight = 300.0;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      floating: false,
      delegate: _ProductHeaderDelegate(
        maxHeight: kImageHeight,
        minHeight: MediaQuery.viewPaddingOf(context).top,
      ),
    );
  }
}

class _ProductHeaderDelegate extends SliverPersistentHeaderDelegate {
  _ProductHeaderDelegate({required this.maxHeight, required this.minHeight})
    : assert(maxHeight >= minHeight),
      assert(minHeight >= 0.0);

  final double maxHeight;
  final double minHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final Product product = context.watch<Product>();
    final double progress = (shrinkOffset / (maxHeight - minHeight)).clamp(
      0.0,
      1.0,
    );

    return Stack(
      children: <Widget>[
        PositionedDirectional(
          top: 0.0,
          start: 0.0,
          end: 0.0,
          height: maxHeight - shrinkOffset,
          child: product.picture != null && product.picture!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: product.picture!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  colorBlendMode: BlendMode.srcATop,
                  placeholder: (context, url) => Container(
                    color: AppColors.grey1,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.blueDark,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.grey1,
                    child: Center(
                      child: SvgPicture.asset(
                        AppVectorialImages.iconImagePlaceholderAlt,
                        width: 64,
                        height: 64,
                        colorFilter: ColorFilter.mode(
                          AppColors.grey2,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                )
              : Container(
                  color: AppColors.grey1,
                  child: Center(
                    child: SvgPicture.asset(
                      AppVectorialImages.iconImagePlaceholder,
                      width: 64,
                      height: 64,
                      colorFilter: ColorFilter.mode(
                        AppColors.grey2,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
        ),
        PositionedDirectional(
          top: max(maxHeight - shrinkOffset - 16.0, 0.0),
          start: 0.0,
          end: 0.0,
          child: Container(
            constraints: BoxConstraints(minHeight: minHeight),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadiusDirectional.vertical(
                top: Radius.circular(16.0 * (1 - progress)),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1 * (1.0 - progress)),
                  blurRadius: 10.0,
                  offset: const Offset(0.0, -2.0),
                ),
              ],
            ),
            child: SizedBox(width: double.infinity, height: 16.0),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant _ProductHeaderDelegate oldDelegate) =>
      maxHeight != oldDelegate.maxHeight || minHeight != oldDelegate.minHeight;
}

class ProductNameHeader extends StatelessWidget {
  const ProductNameHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final Product product = context.read<Product>();

    return SliverPinnedHeader(
      child: Material(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsetsDirectional.only(start: 20.0, end: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(product.name ?? '-', style: context.theme.title1),
              const SizedBox(height: 3.0),
              Text(
                product.brands?.join(', ') ?? '-',
                style: context.theme.title2,
              ),
              const SizedBox(height: 8.0),
            ],
          ),
        ),
      ),
    );
  }
}
