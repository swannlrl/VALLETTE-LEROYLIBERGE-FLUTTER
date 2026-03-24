import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:formation_flutter/api/open_food_facts_api.dart';
import 'package:formation_flutter/api/pocketbase_api.dart';
import 'package:formation_flutter/api/product_cache.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/res/app_vectorial_images.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<_HistoryItem>? _items;
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
      final records = await pb.collection('historique').getFullList(
            sort: '-created',
            filter: 'user = "${pb.authStore.record!.id}"',
          );

      final barcodes = <String>[];
      for (final record in records) {
        final barcode = record.getStringValue('barcode');
        if (barcode.isNotEmpty && !barcodes.contains(barcode)) {
          barcodes.add(barcode);
        }
      }

      // 1. Show cached products immediately
      final initialItems = <_HistoryItem>[];
      for (final barcode in barcodes) {
        final cached = await ProductCache.getCachedProduct(barcode);
        initialItems.add(_HistoryItem(barcode: barcode, product: cached));
      }

      if (mounted) {
        setState(() {
          _items = initialItems;
          _isLoading = false;
        });
      }

      // 2. Refresh from API in parallel batches of 3
      for (int batchStart = 0; batchStart < barcodes.length; batchStart += 3) {
        final batchEnd = (batchStart + 3).clamp(0, barcodes.length);
        final batch = barcodes.sublist(batchStart, batchEnd);

        final futures = batch.asMap().entries.map((entry) async {
          final i = batchStart + entry.key;
          final barcode = entry.value;
          try {
            final result = await OpenFoodFactsAPI().getProduct(barcode);
            await ProductCache.saveProduct(result.product, result.raw);
            if (mounted && _items != null && _items!.length > i) {
              setState(() {
                _items![i] = _HistoryItem(barcode: barcode, product: result.product);
              });
            }
          } catch (_) {}
        });

        await Future.wait(futures);
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

  void _logout() {
    pb.authStore.clear();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Mes scans',
          style: TextStyle(
            color: AppColors.blueDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(AppIcons.tab_barcode),
            color: AppColors.blueDark,
            onPressed: () async {
              await context.push('/scanner');
              _load();
            },
          ),
          IconButton(
            icon: SvgPicture.asset(
              AppVectorialImages.iconStarFilled,
              colorFilter: const ColorFilter.mode(AppColors.yellow, BlendMode.srcIn),
              width: 24,
              height: 24,
            ),
            onPressed: () => context.push('/favorites'),
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app, color: AppColors.blueDark),
            onPressed: _logout,
          ),
        ],
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
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items!.length,
        separatorBuilder: (_, i) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _items![index];
          return _ProductCard(
            barcode: item.barcode,
            product: item.product,
            onTap: () async {
              await context.push('/product', extra: item.barcode);
              _load();
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppVectorialImages.illEmpty,
              width: 200,
            ),
            const SizedBox(height: 24),
            Text(
              'Vous n\'avez pas encore\nscanné de produit',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.grey3,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  await context.push('/scanner');
                  _load();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  foregroundColor: AppColors.blueDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'COMMENCER',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Shared product card widget
// ============================================================

class _ProductCard extends StatelessWidget {
  final String barcode;
  final Product? product;
  final VoidCallback onTap;

  const _ProductCard({
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
              // Product image
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
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: SvgPicture.asset(
                                AppVectorialImages.iconImagePlaceholderAlt,
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
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: SvgPicture.asset(
                              AppVectorialImages.iconImagePlaceholder,
                              colorFilter: ColorFilter.mode(
                                AppColors.grey2,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Product info
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Nutri-Score',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem {
  final String barcode;
  final Product? product;

  _HistoryItem({required this.barcode, this.product});
}