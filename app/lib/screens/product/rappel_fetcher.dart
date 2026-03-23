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
      // Requête directe sur la collection unifiée "rappels"
      final record = await pb.collection('rappels').getFirstListItem(
        'gtin = "$_barcode"',
      );
      state = RappelFound(record);
    } catch (e) {
      state = RappelNotFound();
    }
    notifyListeners(); // Prévient les widgets du changement
  }
}