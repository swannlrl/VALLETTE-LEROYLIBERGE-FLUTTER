import 'package:dio/dio.dart';
import 'package:pocketbase/pocketbase.dart';

class PocketBaseAPI {
  static final PocketBaseAPI _instance = PocketBaseAPI._internal();

  factory PocketBaseAPI() => _instance;

  final PocketBase pb;
  final Dio _dio;

  PocketBaseAPI._internal()
      : pb = PocketBase('http://10.0.2.2:8090'),
        _dio = Dio();

  Future<void> syncDatabase() async {
    try {
      await pb.admins.authWithPassword('swann02.lrl@gmail.com', '1234567890');

      final response = await _dio.get(
        'https://codelabs.formation-flutter.fr/assets/rappels.json',
      );

      final List<dynamic> data = response.data;

      for (var item in data) {
        String gtin = item['gtin'].toString();
        String refFiche = item['numero_fiche'].toString();

        if (gtin == '0' || gtin.isEmpty) continue;

        try {
          String campagneId = "";

          try {
            final existingCampagne = await pb.collection('campagnes').getFirstListItem('reference_fiche="$refFiche"');
            campagneId = existingCampagne.id;
          } catch (e) {
            String imageStr = item['liens_vers_les_images'] ?? '';
            String firstImage = imageStr.contains('|') ? imageStr.split('|').first : imageStr;

            final newCampagne = await pb.collection('campagnes').create(body: {
              'reference_fiche': refFiche,
              'titre': item['libelle'] ?? 'Produit inconnu',
              'image_url': firstImage,
              'motif': item['motif_rappel'] ?? '',
              'conduite': item['conduites_a_tenir_par_le_consommateur'] ?? '',
              'lien_pdf': item['lien_vers_affichette_pdf'] ?? '',
            });
            campagneId = newCampagne.id;
          }

          await pb.collection('produits').create(body: {
            'gtin': gtin,
            'lot': item['identification_produits'] ?? '',
            'campagnes': campagneId,
          });

        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      print("Erreur de synchronisation PocketBase : $e");
    }
  }
}