import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

// Définition des états pour corriger l'erreur 'state'
sealed class RappelFetcherState {}
class RappelFetcherLoading extends RappelFetcherState {}
class RappelFetcherError extends RappelFetcherState {}
class RappelFetcherNotFound extends RappelFetcherState {}
class RappelFetcherFound extends RappelFetcherState {
  final RecordModel record;
  RappelFetcherFound(this.record);
}

class RappelFetcher extends ChangeNotifier {
  RappelFetcher({required String barcode}) : _barcode = barcode {
    _loadRappel();
  }

  final String _barcode;
  // On définit la propriété 'state' attendue par la vue
  RappelFetcherState state = RappelFetcherLoading();
  final pb = PocketBase('http://127.0.0.1:8090');

  Future<void> _loadRappel() async {
    state = RappelFetcherLoading();
    notifyListeners();

    try {
      // On cherche le gtin et on récupère les infos de la campagne liée
      final result = await pb.collection('produits').getFirstListItem(
        'gtin = "$_barcode"',
        expand: 'campagnes',
      );
      state = RappelFetcherFound(result);
    } catch (e) {
      state = RappelFetcherNotFound();
    } finally {
      notifyListeners();
    }
  }
}