import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:formation_flutter/api/pocketbase_api.dart';
import 'package:formation_flutter/res/app_vectorial_images.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:formation_flutter/screens/product/product_fetcher.dart';
import 'package:formation_flutter/screens/product/favorite_notifier.dart';
import 'package:formation_flutter/screens/product/states/empty/product_page_empty.dart';
import 'package:formation_flutter/screens/product/states/error/product_page_error.dart';
import 'package:formation_flutter/screens/product/states/success/product_page_body.dart';
import 'package:formation_flutter/screens/product/rappel_fetcher.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key, required this.barcode})
      : assert(barcode.length > 0);
  final String barcode;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  void initState() {
    super.initState();
    _saveToHistory();
  }

  /// Sauvegarde le scan dans la collection "historique"
  Future<void> _saveToHistory() async {
    try {
      final userId = pb.authStore.record?.id;
      if (userId == null) return;

      await pb.collection('historique').create(body: {
        'user': userId,
        'barcode': widget.barcode,
      });
    } catch (_) {
      // Ignorer silencieusement (pas critique)
    }
  }

  @override
  Widget build(BuildContext context) {
    final materialLocalizations = MaterialLocalizations.of(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProductFetcher>(
            create: (_) => ProductFetcher(barcode: widget.barcode)),
        ChangeNotifierProvider<RappelFetcher>(
            create: (_) => RappelFetcher(barcode: widget.barcode)),
        ChangeNotifierProvider<FavoriteNotifier>(
            create: (_) => FavoriteNotifier(barcode: widget.barcode)),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Consumer<ProductFetcher>(
              builder: (context, notifier, _) {
                return switch (notifier.state) {
                  ProductFetcherLoading() => const ProductPageEmpty(),
                  ProductFetcherError(error: var err) =>
                    ProductPageError(
                      error: err,
                      onRetry: notifier.loadProduct,
                    ),
                  ProductFetcherSuccess(product: var prod) => ProductPageBody(product: prod),
                };
              },
            ),

            // Bouton Fermer (Croix en haut à gauche)
            PositionedDirectional(
              top: 0.0,
              start: 0.0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Tooltip(
                      message: materialLocalizations.closeButtonTooltip,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgPicture.asset(
                            AppVectorialImages.iconBack,
                            colorFilter: ColorFilter.mode(
                              Colors.grey[800]!,
                              BlendMode.srcIn,
                            ),
                            width: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bouton ⭐ Favori (en haut à droite)
            PositionedDirectional(
              top: 0.0,
              end: 0.0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Consumer<FavoriteNotifier>(
                    builder: (context, fav, _) {
                      if (fav.loading) {
                        return const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      return Material(
                        type: MaterialType.transparency,
                        child: Tooltip(
                          message: fav.isFavorite
                              ? 'Retirer des favoris'
                              : 'Ajouter aux favoris',
                          child: InkWell(
                            onTap: () => fav.toggle(),
                            customBorder: const CircleBorder(),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SvgPicture.asset(
                                fav.isFavorite
                                    ? AppVectorialImages.iconStarFilled
                                    : AppVectorialImages.iconStarEmpty,
                                colorFilter: ColorFilter.mode(
                                  fav.isFavorite
                                      ? Colors.amber
                                      : Colors.grey[800]!,
                                  BlendMode.srcIn,
                                ),
                                width: 24,
                                height: 24,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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