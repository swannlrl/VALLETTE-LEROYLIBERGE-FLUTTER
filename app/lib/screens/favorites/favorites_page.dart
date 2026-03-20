import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:formation_flutter/api/open_food_facts_api.dart';
import 'package:formation_flutter/api/product_cache.dart';
import 'package:formation_flutter/api/pocketbase_api.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:go_router/go_router.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<_FavItem>? _items;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final records = await pb.collection('favoris').getFullList(
            sort: '-created',
            filter: 'user = "${pb.authStore.record!.id}"',
          );
      final barcodes = records.map((r) => r.getStringValue('barcode')).where((b) => b.isNotEmpty).toList();

      // Load from cache first
      final cachedItems = <_FavItem>[];
      for (final barcode in barcodes) {
        final cached = await ProductCache.getCachedProduct(barcode);
        cachedItems.add(_FavItem(barcode: barcode, product: cached));
      }

      if (mounted) {
        setState(() {
          _items = cachedItems;
          _isLoading = false;
        });
      }

      // Refresh from API
      for (int i = 0; i < barcodes.length; i++) {
        final barcode = barcodes[i];
        try {
          final result = await OpenFoodFactsAPI().getProduct(barcode);
          await ProductCache.saveProduct(result.product, result.raw);
          if (mounted && _items != null && _items!.length > i) {
            setState(() {
              _items![i] = _FavItem(barcode: barcode, product: result.product);
            });
          }
        } catch (_) {}
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur lors du chargement';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.blueDark),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Mes favoris',
          style: TextStyle(
            color: AppColors.blueDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: TextStyle(color: AppColors.grey3)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Réessayer')),
          ],
        ),
      );
    }

    if (_items == null || _items!.isEmpty) {
      return Center(
        child: Text(
          'Aucun favori pour le moment',
          style: TextStyle(color: AppColors.grey3, fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items!.length,
        separatorBuilder: (_, i) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _items![index];
          return _FavProductCard(
            barcode: item.barcode,
            product: item.product,
            onTap: () async {
              await context.push('/product', extra: item.barcode);
              _load(); // Refresh in case favorite was removed
            },
          );
        },
      ),
    );
  }
}

class _FavProductCard extends StatelessWidget {
  final String barcode;
  final Product? product;
  final VoidCallback onTap;

  const _FavProductCard({
    required this.barcode,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = product;

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: p?.picture != null
                      ? CachedNetworkImage(
                          imageUrl: p!.picture!,
                          fit: BoxFit.cover,
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
                            child: const Icon(Icons.broken_image,
                                color: AppColors.grey2),
                          ),
                        )
                      : Container(
                          color: AppColors.grey1,
                          child: Icon(Icons.fastfood, color: AppColors.grey2),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p?.name ?? barcode,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.blueDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (p?.brands != null && p!.brands!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        p.brands!.first,
                        style: TextStyle(
                          color: AppColors.grey3,
                          fontSize: 14,
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
            ],
          ),
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
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Nutriscore : $label',
          style: TextStyle(
            color: AppColors.grey3,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _FavItem {
  final String barcode;
  final Product? product;

  _FavItem({required this.barcode, this.product});
}
