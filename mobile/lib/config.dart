import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class AppConfig {
  static const String supabaseUrl = 'https://bdjclhwaajitwfxswbtg.supabase.co';
  static const String supabaseKey = 'sb_publishable_7WW2oenBgoE7wcA5mbn7jA_OKieTCFO';

  static String get baseUrl {
    // Production Railway URL
    const String productionUrl = 'https://sumobee-production.up.railway.app';
    
    // Always use production URL unless specifically testing locally
    // For local development with emulator, uncomment the logic below
    return productionUrl;

    /*
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    
    String url = 'http://127.0.0.1:8000';
    try {
      if (Platform.isAndroid) {
        url = 'http://10.0.2.2:8000'; 
      }
    } catch (e) {}
    return url;
    */
  }
}
