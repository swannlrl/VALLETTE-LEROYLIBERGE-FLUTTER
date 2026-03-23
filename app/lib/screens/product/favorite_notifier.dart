import 'package:flutter/material.dart';
import 'package:formation_flutter/api/pocketbase_api.dart';

/// Gère la logique de favori pour un produit
class FavoriteNotifier extends ChangeNotifier {
  FavoriteNotifier({required String barcode}) : _barcode = barcode {
    _checkFavorite();
  }

  final String _barcode;
  bool _isFavorite = false;
  bool _loading = true;

  bool get isFavorite => _isFavorite;
  bool get loading => _loading;

  Future<void> _checkFavorite() async {
    try {
      final userId = pb.authStore.record?.id;
      if (userId == null) return;

      final result = await pb.collection('favoris').getList(
            filter: 'user = "$userId" && barcode = "$_barcode"',
            perPage: 1,
          );

      _isFavorite = result.items.isNotEmpty;
    } catch (_) {
      _isFavorite = false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> toggle() async {
    final userId = pb.authStore.record?.id;
    if (userId == null) return;

    try {
      if (_isFavorite) {
        // Retirer des favoris
        final result = await pb.collection('favoris').getList(
              filter: 'user = "$userId" && barcode = "$_barcode"',
              perPage: 1,
            );
        if (result.items.isNotEmpty) {
          await pb.collection('favoris').delete(result.items.first.id);
        }
        _isFavorite = false;
      } else {
        // Ajouter aux favoris
        await pb.collection('favoris').create(body: {
          'user': userId,
          'barcode': _barcode,
        });
        _isFavorite = true;
      }
    } catch (_) {
      // Ignorer les erreurs silencieusement
    }
    notifyListeners();
  }
}
