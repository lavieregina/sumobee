import 'package:flutter/material.dart';
import 'package:sumobee/services/localization_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:sumobee/services/sharing_service.dart';
import 'package:sumobee/services/api_service.dart';
import 'package:sumobee/screens/preview_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumobee/screens/dashboard_screen.dart';

import 'package:sumobee/config.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sumobee/services/analytics_service.dart';
import 'package:sumobee/firebase_options.dart';
import 'package:sumobee/screens/history_screen.dart';

final appLanguageNotifier = ValueNotifier<String>('繁體中文');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseKey,
  );

  // 初始化 Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase 初始化失敗: $e');
  }

  runApp(const SumoBeeApp());
}

class SumoBeeApp extends StatelessWidget {
  const SumoBeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguageNotifier,
      builder: (context, lang, child) {
        return MaterialApp(
          title: 'SumoBee',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primaryColor: const Color(0xFFFFC107), // Amber Bee Yellow
            scaffoldBackgroundColor: const Color(0xFF0F0F0F), // Jet Black
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFFC107),
              brightness: Brightness.dark,
              primary: const Color(0xFFFFC107),
              surface: const Color(0xFF1E1E1E),
            ),
            textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
            cardTheme: CardThemeData(
              color: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                foregroundColor: Colors.black,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          home: kIsWeb 
            ? MobileSimulatorWrapper(child: const HomeScreen())
            : const HomeScreen(),
        );
      },
    );
  }
}

class MobileSimulatorWrapper extends StatelessWidget {
  final Widget child;
  const MobileSimulatorWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 375, // Standard mobile width
          height: 812, // Standard mobile height
          margin: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white10, width: 8),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.1),
                blurRadius: 100,
                spreadRadius: 10,
              )
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              child,
              // Simulator Overlay Button
              Positioned(
                bottom: 80,
                right: 20,
                child: FloatingActionButton.small(
                  onPressed: () => _simulateShare(context),
                  backgroundColor: Colors.white24,
                  child: const Icon(Icons.bolt, color: Colors.amber),
                  tooltip: '模擬 YouTube 分享',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _simulateShare(BuildContext context) {
    // This simulates the behavior of SharingService
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    if (homeState != null) {
      homeState.handleSharedUrl('https://www.youtube.com/watch?v=dQw4w9WgXcQ');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚡ 模擬從 YouTube 分享影片...'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _sharingService = SharingService();
  final _apiService = ApiService(baseUrl: AppConfig.baseUrl); 
  bool _isProcessing = false;
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const HistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialLanguage();
    _sharingService.initSharing((url) => handleSharedUrl(url));
  }

  Future<void> _loadInitialLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    appLanguageNotifier.value = prefs.getString('appLanguage') ?? '繁體中文';
  }

  Future<void> handleSharedUrl(String url) async {
    setState(() {
      _currentIndex = 0; // Return to dashboard
      _isProcessing = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final groqKey = prefs.getString('groqApiKey');
      
      final res = await _apiService.summarizeVideo(
        url, 
        'f49d8a5a-82e1-4e58-be68-d5033fd35002', // test user
        groqApiKey: groqKey,
      );
      final taskId = res['taskId'];
      final videoId = res['videoId'] ?? 'unknown';
      
      // Log Analytics: 摘要開始
      await AnalyticsService.logSummarizationStarted(videoId);
      
      _pollStatus(taskId, videoId: videoId);
    } catch (e) {
      setState(() => _isProcessing = false);
      _showError(e.toString());
    }
  }

  Future<void> _pollStatus(String taskId, {String? videoId}) async {
    while (true) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) break;
      
      try {
        final res = await _apiService.getTaskStatus(taskId);
        if (res['status'] == 'success') {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PreviewScreen(
                content: res['content'],
                taskId: taskId,
              ),
            ),
          );
          // Log Analytics: 摘要成功
          await AnalyticsService.logSummarizationSuccess(videoId ?? 'unknown');
          
          setState(() => _isProcessing = false);
          break;
        } else if (res['status'] == 'error') {
          // Log Analytics: 摘要失敗
          await AnalyticsService.logSummarizationError(res['error_message']);
          
          setState(() => _isProcessing = false);
          _showError(res['error_message']);
          break;
        }
      } catch (e) {
        setState(() => _isProcessing = false);
        _showError('連線中斷：$e');
        break;
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = appLanguageNotifier.value;
    
    if (_isProcessing) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFFFFC107)),
              const SizedBox(height: 24),
              Text(
                LocalizationService.getString('summarizing', lang),
                style: const TextStyle(fontSize: 16)
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF1E1E1E),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            label: LocalizationService.getString('groq_settings', lang).split(' ')[0], // Using a snippet for now
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history_outlined),
            activeIcon: const Icon(Icons.history),
            label: LocalizationService.getString('history', lang),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sharingService.dispose();
    super.dispose();
  }
}
