import 'package:flutter/material.dart';
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/screens/product/product_fetcher.dart';
import 'package:formation_flutter/screens/product/states/empty/product_page_empty.dart';
import 'package:formation_flutter/screens/product/states/error/product_page_error.dart';
import 'package:formation_flutter/screens/product/states/success/product_page_body.dart';
import 'package:provider/provider.dart';
import 'package:formation_flutter/screens/product/rappel_fetcher.dart';
import 'package:go_router/go_router.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key, required this.barcode}) : assert(barcode.length > 0);
  final String barcode;

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations materialLocalizations = MaterialLocalizations.of(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProductFetcher>(create: (_) => ProductFetcher(barcode: barcode)),
        ChangeNotifierProvider<RappelFetcher>(create: (_) => RappelFetcher(barcode: barcode)),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // --- PARTIE PRINCIPALE ---
            Column(
              children: [
                // 1. Zone Nutrition / Infos Produit (Open Food Facts)
                Expanded(
                  child: Consumer<ProductFetcher>(
                    builder: (context, notifier, _) {
                      return switch (notifier.state) {
                        ProductFetcherLoading() => const ProductPageEmpty(),
                        // Si erreur 500, on affiche l'erreur en haut, mais on ne bloque pas le reste
                        ProductFetcherError(error: var err) => ProductPageError(error: err),
                        ProductFetcherSuccess() => const ProductPageBody(),
                      };
                    },
                  ),
                ),

                // 2. Zone Rappel Produit (PocketBase)
                const _RappelBanner(),
              ],
            ),

            // --- BOUTON FERMER (HEADER) ---
            PositionedDirectional(
              top: 0.0,
              start: 0.0,
              child: _HeaderIcon(
                icon: AppIcons.close,
                tooltip: materialLocalizations.closeButtonTooltip,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget interne pour le bandeau de rappel interactif
class _RappelBanner extends StatelessWidget {
  const _RappelBanner();

  @override
  Widget build(BuildContext context) {
    return Consumer<RappelFetcher>(
      builder: (context, rappelNotifier, child) {
        final state = rappelNotifier.state;

        // On n'affiche le bandeau que si un rappel est trouvé dans PocketBase
        if (state is RappelFetcherFound) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0), // Marges demandées
            child: InkWell(
              onTap: () => context.push('/rappel-detail', extra: state.record), // Vers l'écran détail
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  // Couleur #FF0000 avec 36% d'opacité
                  color: const Color(0xFFFF0000).withOpacity(0.36),
                  borderRadius: BorderRadius.circular(12), // Arrondi 12px
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Ce produit fait l'objet d'un rappel produit",
                        style: TextStyle(
                          // Couleur #A60000
                          color: Color(0xFFA60000),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: Color(0xFFA60000),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        // Sinon, on n'affiche rien du tout
        return const SizedBox.shrink();
      },
    );
  }
}

/// Bouton d'icône pour le header
class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.tooltip, this.onPressed});
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          type: MaterialType.transparency,
          child: Tooltip(
            message: tooltip,
            child: InkWell(
              onTap: onPressed ?? () {},
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(icon, color: Colors.grey[800]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}