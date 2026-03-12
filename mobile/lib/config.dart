import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class AppConfig {
  static const String supabaseUrl = 'https://bdjclhwaajitwfxswbtg.supabase.co';
  static const String supabaseKey = 'sb_publishable_7WW2oenBgoE7wcA5mbn7jA_OKieTCFO';

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    
    // Default fallback (Android Emulator host address is 10.0.2.2)
    String url = 'http://127.0.0.1:8000';
    
    try {
      if (Platform.isAndroid) {
        // If you are using a physical device, change this to your computer's IP
        // If you are using an emulator, use 10.0.2.2
        url = 'http://10.0.2.2:8000'; 
      }
    } catch (e) {
      // Fallback for other platforms
    }
    return url;
  }
}
