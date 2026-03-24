import 'package:flutter/material.dart';
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/res/app_theme_extension.dart';
import 'package:provider/provider.dart';

class ProductTab0 extends StatelessWidget {
  const ProductTab0({super.key});

  static const double _kHorizontalPadding = 20.0;

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _Scores(),
        Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: _kHorizontalPadding,
            vertical: 30.0,
          ),
          child: _Info(),
        ),
      ],
    );
  }
}

class _Scores extends StatelessWidget {
  const _Scores();

  static const double _horizontalPadding = ProductTab0._kHorizontalPadding;
  static const double _verticalPadding = 18.0;

  @override
  Widget build(BuildContext context) {
    final Product product = context.watch<Product>();

    return DefaultTextStyle(
      style: context.theme.altText,
      child: Container(
        color: AppColors.grey1,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                vertical: _verticalPadding,
                horizontal: _horizontalPadding,
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 44,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 5.0),
                        child: _Nutriscore(
                          nutriscore:
                              product.nutriScore ?? ProductNutriScore.unknown,
                        ),
                      ),
                    ),
                    const VerticalDivider(),
                    Expanded(
                      flex: 66,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 25.0),
                        child: _NovaGroup(
                          novaScore:
                              product.novaScore ?? ProductNovaScore.unknown,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                vertical: _verticalPadding,
                horizontal: _horizontalPadding,
              ),
              child: _GreenScore(
                greenScore: product.greenScore ?? ProductGreenScore.unknown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Nutriscore extends StatelessWidget {
  const _Nutriscore({required this.nutriscore});

  final ProductNutriScore nutriscore;

  @override
  Widget build(BuildContext context) {
    final assetName = _findAssetName();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppLocalizations.of(context)!.nutriscore,
          style: context.theme.title3,
        ),
        const SizedBox(height: 5.0),
        if (assetName != null)
          Image.asset(assetName, height: 42.0)
        else
          Text('Non renseigné', style: TextStyle(color: AppColors.grey2)),
      ],
    );
  }

  String? _findAssetName() {
    return switch (nutriscore) {
      ProductNutriScore.A => 'res/drawables/nutriscore_a.png',
      ProductNutriScore.B => 'res/drawables/nutriscore_b.png',
      ProductNutriScore.C => 'res/drawables/nutriscore_c.png',
      ProductNutriScore.D => 'res/drawables/nutriscore_d.png',
      ProductNutriScore.E => 'res/drawables/nutriscore_e.png',
      ProductNutriScore.unknown => null,
    };
  }
}

class _NovaGroup extends StatelessWidget {
  const _NovaGroup({required this.novaScore});

  final ProductNovaScore novaScore;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppLocalizations.of(context)!.nova_group,
          style: context.theme.title3,
        ),
        const SizedBox(height: 5.0),
        Row(
          children: [
            if (novaScore != ProductNovaScore.unknown)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _findColor(),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  _findLevelString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (novaScore != ProductNovaScore.unknown)
              const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                _findLabel(),
                style: const TextStyle(color: AppColors.grey2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _findColor() {
    return switch (novaScore) {
      ProductNovaScore.group1 => AppColors.nova1,
      ProductNovaScore.group2 => AppColors.nova2,
      ProductNovaScore.group3 => AppColors.nova3,
      ProductNovaScore.group4 => AppColors.nova4,
      ProductNovaScore.unknown => AppColors.grey2,
    };
  }

  String _findLevelString() {
    return switch (novaScore) {
      ProductNovaScore.group1 => '1',
      ProductNovaScore.group2 => '2',
      ProductNovaScore.group3 => '3',
      ProductNovaScore.group4 => '4',
      ProductNovaScore.unknown => '?',
    };
  }

  String _findLabel() {
    return switch (novaScore) {
      ProductNovaScore.group1 =>
        'Aliments non transformés ou transformés minimalement',
      ProductNovaScore.group2 => 'Ingrédients culinaires transformés',
      ProductNovaScore.group3 => 'Aliments transformés',
      ProductNovaScore.group4 =>
        'Produits alimentaires et boissons ultra-transformés',
      ProductNovaScore.unknown => 'Score non calculé',
    };
  }
}

class _GreenScore extends StatelessWidget {
  const _GreenScore({required this.greenScore});

  final ProductGreenScore greenScore;

  @override
  Widget build(BuildContext context) {
    final icon = _findIcon();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppLocalizations.of(context)!.greenscore,
          style: context.theme.title3,
        ),
        const SizedBox(height: 5.0),
        Row(
          children: <Widget>[
            if (icon != null)
              Icon(icon, color: _findIconColor(), size: 42.0)
            else
              Text('Non renseigné', style: TextStyle(color: AppColors.grey2)),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                _findLabel(),
                style: const TextStyle(color: AppColors.grey2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData? _findIcon() {
    return switch (greenScore) {
      ProductGreenScore.APlus => AppIcons.ecoscore_a_plus,
      ProductGreenScore.A => AppIcons.ecoscore_a,
      ProductGreenScore.B => AppIcons.ecoscore_b,
      ProductGreenScore.C => AppIcons.ecoscore_c,
      ProductGreenScore.D => AppIcons.ecoscore_d,
      ProductGreenScore.E => AppIcons.ecoscore_e,
      ProductGreenScore.F => AppIcons.ecoscore_f,
      ProductGreenScore.unknown => null,
    };
  }

  Color _findIconColor() {
    return switch (greenScore) {
      ProductGreenScore.APlus => AppColors.greenScoreAPlus,
      ProductGreenScore.A => AppColors.greenScoreA,
      ProductGreenScore.B => AppColors.greenScoreB,
      ProductGreenScore.C => AppColors.greenScoreC,
      ProductGreenScore.D => AppColors.greenScoreD,
      ProductGreenScore.E => AppColors.greenScoreE,
      ProductGreenScore.F => AppColors.greenScoreF,
      ProductGreenScore.unknown => AppColors.grey2,
    };
  }

  String _findLabel() {
    return switch (greenScore) {
      ProductGreenScore.APlus => 'Très faible impact environnemental',
      ProductGreenScore.A => 'Très faible impact environnemental',
      ProductGreenScore.B => 'Faible impact environnemental',
      ProductGreenScore.C => "Impact modéré sur l'environnement",
      ProductGreenScore.D => 'Impact environnemental élevé',
      ProductGreenScore.E => 'Impact environnemental très élevé',
      ProductGreenScore.F => 'Impact environnemental très élevé',
      ProductGreenScore.unknown => 'Score non calculé',
    };
  }
}

class _Info extends StatelessWidget {
  const _Info();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final Product product = context.watch<Product>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _ProductItemValue(
          label: localizations.product_quantity,
          value: product.quantity ?? '-',
        ),
        _ProductItemValue(
          label: localizations.product_countries,
          value: product.manufacturingCountries?.join(', ') ?? '-',
          includeDivider: false,
        ),
        const SizedBox(height: 15.0),
        Row(
          children: <Widget>[
            Expanded(
              flex: 40,
              child: _ProductBubble(
                label: localizations.product_vegan,
                value: product.isVegan == ProductAnalysis.yes
                    ? _ProductBubbleValue.on
                    : _ProductBubbleValue.off,
              ),
            ),
            Spacer(flex: 10),
            Expanded(
              flex: 40,
              child: _ProductBubble(
                label: localizations.product_vegetarian,
                value: product.isVegetarian == ProductAnalysis.yes
                    ? _ProductBubbleValue.on
                    : _ProductBubbleValue.off,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProductItemValue extends StatelessWidget {
  const _ProductItemValue({
    required this.label,
    required this.value,
    this.includeDivider = true,
  });

  final String label;
  final String value;
  final bool includeDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 12.0),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(label)),
              Expanded(child: Text(value, textAlign: TextAlign.end)),
            ],
          ),
        ),
        if (includeDivider) const Divider(height: 1.0),
      ],
    );
  }
}

class _ProductBubble extends StatelessWidget {
  const _ProductBubble({required this.label, required this.value});

  final String label;
  final _ProductBubbleValue value;

  @override
  Widget build(BuildContext context) {
    final bool isOn = value == _ProductBubbleValue.on;
    final Color bg = isOn ? AppColors.blueLight : const Color(0xFFE05252);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: 10.0,
        horizontal: 15.0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            isOn ? AppIcons.checkmark : AppIcons.close,
            color: AppColors.white,
            size: 16.0,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ProductBubbleValue { on, off }
