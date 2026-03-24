import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:formation_flutter/model/product.dart';

class OpenFoodFactsAPI {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2';
  static const String _corsProxy = 'https://corsproxy.io/?';

  // Singleton
  static final OpenFoodFactsAPI _instance = OpenFoodFactsAPI._internal();

  factory OpenFoodFactsAPI() => _instance;

  final Dio _dio;

  OpenFoodFactsAPI._internal() : _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'User-Agent': 'FlutterFormationApp - Android - Version 1.0',
    },
  ));

  String _buildUrl(String path) {
    final url = '$_baseUrl$path';
    if (kIsWeb) {
      return '$_corsProxy${Uri.encodeComponent(url)}';
    }
    return url;
  }

  Future<({Product product, Map<String, dynamic> raw})> getProduct(
      String barcode) async {
    try {
      final response = await _dio.get(_buildUrl('/product/$barcode.json'));

      if (response.data == null || response.data['status'] != 1) {
        throw Exception('Produit introuvable sur Open Food Facts');
      }

      final Map<String, dynamic> data = response.data['product'];
      return (product: Product.fromJson(data), raw: data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connexion trop lente, réessayez');
      }
      throw Exception('Erreur réseau: ${e.message}');
    }
  }
}

