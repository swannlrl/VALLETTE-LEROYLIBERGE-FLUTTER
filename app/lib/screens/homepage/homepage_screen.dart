import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:formation_flutter/api/open_food_facts_api.dart';
import 'package:formation_flutter/api/pocketbase_api.dart';
import 'package:formation_flutter/api/product_cache.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/res/app_vectorial_images.dart';
import 'package:formation_flutter/widgets/product_list_item.dart';
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
        title: const Text(
          'Mes scans',
          style: TextStyle(
            color: AppColors.blue,
            fontWeight: FontWeight.w800,
            fontFamily: 'Avenir',
            fontSize: 20,
            letterSpacing: -0.4,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          if (_items != null && _items!.isNotEmpty)
            IconButton(
              icon: const Icon(AppIcons.barcode, size: 26),
              color: AppColors.blue,
              onPressed: () async {
                await context.push('/scanner');
                _load();
              },
            ),
          IconButton(
            icon: SvgPicture.asset(
              AppVectorialImages.iconStarFilled,
              colorFilter: const ColorFilter.mode(AppColors.blue, BlendMode.srcIn),
              width: 26,
              height: 26,
            ),
            onPressed: () => context.push('/favorites'),
          ),
          IconButton(
            icon: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: AppColors.white,
                size: 18,
              ),
            ),
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
            Text(_error!, style: const TextStyle(color: AppColors.grey3)),
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
          return ProductListItem(
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
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppVectorialImages.illEmpty,
              width: 250,
            ),
            const SizedBox(height: 32),
            const Text(
              'Vous n\'avez pas encore\nscanné de produit',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.blue,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Avenir',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 250,
              height: 45,
              child: ElevatedButton(
                onPressed: () async {
                  await context.push('/scanner');
                  _load();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  foregroundColor: AppColors.blue,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'COMMENCER',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        fontFamily: 'Avenir',
                        letterSpacing: -0.36,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
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



class _HistoryItem {
  final String barcode;
  final Product? product;

  _HistoryItem({required this.barcode, this.product});
}