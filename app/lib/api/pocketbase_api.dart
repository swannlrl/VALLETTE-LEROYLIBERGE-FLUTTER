import 'package:pocketbase/pocketbase.dart';

class PocketBaseAPI {
  // Singleton pour utiliser la même instance partout
  static final PocketBaseAPI _instance = PocketBaseAPI._internal();
  factory PocketBaseAPI() => _instance;

  final PocketBase pb;

  // Remplace localhost par 127.0.0.1 pour éviter les soucis DNS de Chrome
  PocketBaseAPI._internal() : pb = PocketBase('http://127.0.0.1:8090');

  // Tu peux garder cette petite fonction pour t'identifier au démarrage si besoin
  Future<void> init() async {
    try {
      await pb.admins.authWithPassword('swann02.lrl@gmail.com', '1234567890');
      print("✅ Connecté au serveur PocketBase");
    } catch (e) {
      print("❌ Erreur de connexion au serveur : $e");
    }
  }
}