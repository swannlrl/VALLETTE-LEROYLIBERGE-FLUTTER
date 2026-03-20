import 'package:flutter/material.dart';
import 'package:formation_flutter/api/open_food_facts_api.dart';
import 'package:formation_flutter/api/product_cache.dart';
import 'package:formation_flutter/model/product.dart';

class ProductFetcher extends ChangeNotifier {
  ProductFetcher({required String barcode})
    : _barcode = barcode,
      _state = ProductFetcherLoading() {
    loadProduct();
  }

  final String _barcode;
  ProductFetcherState _state;

  Future<void> _loadFromCache() async {
    final cached = await ProductCache.getCachedProduct(_barcode);
    if (cached != null) {
      _state = ProductFetcherSuccess(cached);
      notifyListeners();
    }
  }

  // Removed _parseScoreFromCache as it's no longer needed with full Product cache

  Future<void> loadProduct() async {
    if (_state is! ProductFetcherSuccess) {
      _state = ProductFetcherLoading();
      notifyListeners();
      await _loadFromCache();
    }

    try {
      final result = await OpenFoodFactsAPI().getProduct(_barcode);
      await ProductCache.saveProduct(result.product, result.raw);
      _state = ProductFetcherSuccess(result.product);
    } catch (error) {
      debugPrint('ProductFetcher Error for $_barcode: $error');
      if (_state is! ProductFetcherSuccess) {
        _state = ProductFetcherError(error);
      }
    } finally {
      notifyListeners();
    }
  }

  ProductFetcherState get state => _state;
}

sealed class ProductFetcherState {}

class ProductFetcherLoading extends ProductFetcherState {}

class ProductFetcherSuccess extends ProductFetcherState {
  ProductFetcherSuccess(this.product);

  final Product product;
}

class ProductFetcherError extends ProductFetcherState {
  ProductFetcherError(this.error);

  final dynamic error;
}
