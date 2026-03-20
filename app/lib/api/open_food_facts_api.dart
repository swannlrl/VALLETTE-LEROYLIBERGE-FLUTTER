import 'package:dio/dio.dart';
import 'package:formation_flutter/model/product.dart';

class OpenFoodFactsAPI {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2';

  // Singleton
  static final OpenFoodFactsAPI _instance = OpenFoodFactsAPI._internal();

  factory OpenFoodFactsAPI() => _instance;

  final Dio _dio;

  OpenFoodFactsAPI._internal() : _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    headers: {
      'User-Agent': 'FlutterFormationApp - Android - Version 1.0',
    },
  ));

  Future<({Product product, Map<String, dynamic> raw})> getProduct(
      String barcode) async {
    final response = await _dio.get('/product/$barcode.json');

    if (response.data['status'] != 1) {
      throw Exception('Produit introuvable sur Open Food Facts');
    }

    final Map<String, dynamic> data = response.data['product'];
    return (product: Product.fromJson(data), raw: data);
  }
}
