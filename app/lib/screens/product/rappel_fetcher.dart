import 'package:flutter/material.dart';
import 'package:formation_flutter/api/pocketbase_api.dart';
import 'package:pocketbase/pocketbase.dart';

sealed class RappelState {}
class RappelLoading extends RappelState {}
class RappelNotFound extends RappelState {}
class RappelFound extends RappelState {
  final RecordModel record;
  RappelFound(this.record);
}

class RappelFetcher extends ChangeNotifier {
  RappelFetcher({required String barcode}) : _barcode = barcode {
    _load();
  }

  final String _barcode;
  RappelState state = RappelLoading();

  Future<void> _load() async {
    try {
      // Normaliser le barcode en EAN-13 (même format que le serveur)
      final padded = _barcode.padLeft(13, '0');
      final unpadded = _barcode.replaceFirst(RegExp(r'^0+'), '');

      RecordModel? record;

      // Essayer d'abord avec le barcode tel quel
      try {
        record = await pb.collection('rappels').getFirstListItem(
          'gtin = "$_barcode"',
        );
      } catch (_) {}

      // Si non trouvé, essayer avec le padding EAN-13
      if (record == null && padded != _barcode) {
        try {
          record = await pb.collection('rappels').getFirstListItem(
            'gtin = "$padded"',
          );
        } catch (_) {}
      }

      // Si toujours non trouvé, essayer sans zéros initiaux
      if (record == null && unpadded != _barcode) {
        try {
          record = await pb.collection('rappels').getFirstListItem(
            'gtin = "$unpadded"',
          );
        } catch (_) {}
      }

      state = record != null ? RappelFound(record) : RappelNotFound();
    } catch (e) {
      state = RappelNotFound();
    }
    notifyListeners();
  }
}
