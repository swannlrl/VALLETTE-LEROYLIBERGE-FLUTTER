import 'package:pocketbase/pocketbase.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

// Automatically use 127.0.0.1 if running on Web (Chrome debug), 
// otherwise use the local network IP for mobile testing.
final String _pbUrl = kIsWeb 
    ? 'http://127.0.0.1:8090' 
    : 'http://192.168.1.16:8090';

final pb = PocketBase(_pbUrl);