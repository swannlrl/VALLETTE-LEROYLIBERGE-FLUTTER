import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:formation_flutter/model/product.dart';

class ProductCache {
  static const String _key = 'product_cache_v2';

  static Future<void> saveProduct(Product product, Map<String, dynamic> rawJson) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = prefs.getString(_key);
    final Map<String, dynamic> cache =
        cacheJson != null ? jsonDecode(cacheJson) as Map<String, dynamic> : {};

    cache[product.barcode] = rawJson;

    await prefs.setString(_key, jsonEncode(cache));
  }

  static Future<Product?> getCachedProduct(String barcode) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = prefs.getString(_key);
    if (cacheJson == null) return null;

    final Map<String, dynamic> cache = jsonDecode(cacheJson) as Map<String, dynamic>;
    final data = cache[barcode];
    if (data == null) return null;

    try {
      return Product.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
