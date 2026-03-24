import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:formation_flutter/api/open_food_facts_api.dart';
import 'package:formation_flutter/api/product_cache.dart';
import 'package:formation_flutter/api/pocketbase_api.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_vectorial_images.dart';
import 'package:formation_flutter/widgets/product_list_item.dart';
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

      // Refresh from API in parallel batches of 3
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
                _items![i] = _FavItem(barcode: barcode, product: result.product);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset(
            AppVectorialImages.iconBack,
            colorFilter: const ColorFilter.mode(AppColors.blue, BlendMode.srcIn),
            width: 24,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Mes favoris',
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
      return Center(
        child: Text(
          'Aucun favori pour le moment',
          style: const TextStyle(color: AppColors.grey3, fontSize: 16),
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
          return ProductListItem(
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



class _FavItem {
  final String barcode;
  final Product? product;

  _FavItem({required this.barcode, this.product});
}
