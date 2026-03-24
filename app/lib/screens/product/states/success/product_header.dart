import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_vectorial_images.dart';
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
              ? Image.network(
                  product.picture!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) =>
                      progress == null
                          ? child
                          : Container(
                              color: AppColors.grey1,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.blueDark,
                                ),
                              ),
                            ),
                  errorBuilder: (context, error, stack) => Container(
                    color: AppColors.grey1,
                    child: Center(
                      child: SvgPicture.asset(
                        AppVectorialImages.iconImagePlaceholderAlt,
                        width: 64,
                        height: 64,
                        colorFilter: const ColorFilter.mode(
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
                      colorFilter: const ColorFilter.mode(
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
                top: Radius.circular(25.0 * (1 - progress)),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1 * (1.0 - progress)),
                  blurRadius: 10.0,
                  offset: const Offset(0.0, -2.0),
                ),
              ],
            ),
            child: const SizedBox(width: double.infinity, height: 25.0),
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
          padding: const EdgeInsetsDirectional.only(start: 20.0, end: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                product.name ?? '-',
                style: const TextStyle(
                  fontFamily: 'Avenir',
                  fontWeight: FontWeight.w800,
                  fontSize: 28.0,
                  color: Color(0xFF080040),
                  letterSpacing: -0.45,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                product.brands?.join(', ') ?? '-',
                style: const TextStyle(
                  fontFamily: 'Avenir',
                  fontWeight: FontWeight.w400,
                  fontSize: 17.0,
                  color: Color(0xFFB8BBC6),
                  letterSpacing: -0.27,
                ),
              ),
              if (product.altName != null && product.altName!.isNotEmpty) ...[
                const SizedBox(height: 8.0),
                Text(
                  product.altName!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF6A6A6A),
                    fontSize: 17.0,
                    fontFamily: 'Avenir',
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.48,
                  ),
                ),
              ],
              const SizedBox(height: 15.0),
            ],
          ),
        ),
      ),
    );
  }
}
