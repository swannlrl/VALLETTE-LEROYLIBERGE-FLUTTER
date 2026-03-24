import 'package:pocketbase/pocketbase.dart';

// URL PocketBase — utiliser l'IP locale du PC pour tester sur iPhone physique.
// Sur émulateur Android : http://10.0.2.2:8090
// Sur iPhone (même réseau WiFi) : http://<IP_DU_PC>:8090
// Lancer PocketBase avec : .\pocketbase.exe serve --http=0.0.0.0:8090
const _pbUrl = 'http://192.168.1.16:8090';

final pb = PocketBase(_pbUrl);