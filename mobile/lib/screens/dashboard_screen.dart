import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sumobee/services/api_service.dart';
import 'package:sumobee/screens/preview_screen.dart';
import 'package:sumobee/config.dart';
import 'package:sumobee/screens/settings_screen.dart';
import 'package:sumobee/services/localization_service.dart';
import 'package:sumobee/main.dart'; // For appLanguageNotifier

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  final TextEditingController _groqKeyController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final ApiService _apiService = ApiService(baseUrl: AppConfig.baseUrl);
  bool _groqKeySaved = false;
  bool _isProcessing = false;
  String? _processingStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadKeys();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _groqKeyController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkClipboard();
    }
  }

  Future<void> _checkClipboard() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    String? text = data?.text?.trim();
    
    if (text != null && text.startsWith('gsk_') && text != _groqKeyController.text) {
      if (!mounted) return;
      
      // Auto-fill and show a hint
      setState(() {
        _groqKeyController.text = text;
        _groqKeySaved = false; // Require saving
      });
      
      _showToast('📋 已偵測到剪貼簿中的 Groq 金鑰，已自動填入', isError: false);
    }
  }

  Future<void> _loadKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final groq = prefs.getString('groqApiKey') ?? '';
    setState(() {
      _groqKeyController.text = groq;
      _groqKeySaved = groq.isNotEmpty;
    });
  }

  Future<void> _saveGroqKey() async {
    final value = _groqKeyController.text.trim();
    if (value.isEmpty) {
      _showToast('請輸入 Groq API Key', isError: true);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('groqApiKey', value);
    setState(() => _groqKeySaved = true);
    _showToast('✅ Groq API Key 已就緒', isError: false);
  }

  void _showToast(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.teal.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _launchGroqConsole() async {
    final Uri url = Uri.parse('https://console.groq.com/keys');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _showToast('無法開啟網頁', isError: true);
    }
  }

  Future<void> _summarizeUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showToast('請輸入 YouTube 網址', isError: true);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final groqKey = prefs.getString('groqApiKey') ?? '';

    if (groqKey.isEmpty) {
      _showToast('請先設定右上方免費的 Groq API Key', isError: true);
      return;
    }

    setState(() {
      _isProcessing = true;
      _processingStatus = '正在從 YouTube 擷取內容...';
    });

    try {
      final language = prefs.getString('outputLanguage') ?? '繁體中文';
      final detail = prefs.getString('summaryDetail') ?? '精簡 (Concise)';

      final res = await _apiService.summarizeVideo(
        url,
        'f49d8a5a-82e1-4e58-be68-d5033fd35002', // test user
        groqApiKey: groqKey,
        language: language,
        summaryDetail: detail,
      );
      final taskId = res['taskId'] as String;

      setState(() => _processingStatus = '正在透過 Groq AI 生成摘要...');

      while (true) {
        await Future.delayed(const Duration(seconds: 3));
        if (!mounted) break;
        final status = await _apiService.getTaskStatus(taskId);
        if (status['status'] == 'success') {
          if (!mounted) return;
          setState(() => _isProcessing = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PreviewScreen(
                content: status['content'],
                taskId: taskId,
              ),
            ),
          );
          _urlController.clear();
          break;
        } else if (status['status'] == 'error') {
          setState(() => _isProcessing = false);
          _showToast(status['error_message'], isError: true);
          break;
        }
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showToast('連線失敗：$e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = appLanguageNotifier.value;

    return Scaffold(
      body: _isProcessing
          ? _buildLoadingState()
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1E1E1E), Color(0xFF0F0F0F)],
                ),
              ),
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(theme),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          _buildApiKeySection(theme),
                          const SizedBox(height: 40),
                          _buildInputSection(theme),
                          const SizedBox(height: 40),
                          _buildGuideSection(theme),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    final lang = appLanguageNotifier.value;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              color: Color(0xFFFFC107),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            _processingStatus ?? LocalizationService.getString('summarizing', lang),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Processing...', style: TextStyle(color: Colors.grey)), // Simplified for loading
        ],
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1E1E1E), // Solid background when pinned
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 12),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Text(
              'SumoBee',
              style: TextStyle(
                color: Color(0xFFFFC107),
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.primaryColor.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings_outlined, color: theme.primaryColor),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }


  Widget _buildApiKeySection(ThemeData theme) {
    final lang = appLanguageNotifier.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.vpn_key_outlined, size: 20, color: Colors.amber),
            const SizedBox(width: 8),
            Text(LocalizationService.getString('groq_settings', lang), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton(
              onPressed: _launchGroqConsole,
              child: Row(
                children: [
                  Text(LocalizationService.getString('get_api_key', lang), style: const TextStyle(color: Colors.amber)),
                  const SizedBox(width: 4),
                  const Icon(Icons.open_in_new, size: 14, color: Colors.amber),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _groqKeyController,
                  obscureText: true,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'gsk_...',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _groqKeySaved = false),
                ),
              ),
              _groqKeySaved
                  ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20)
                  : InkWell(
                      onTap: _saveGroqKey,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('儲存', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '💡 ${LocalizationService.getString('auto_fill_desc', lang)}',
          style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildInputSection(ThemeData theme) {
    final lang = appLanguageNotifier.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('🎬 ${LocalizationService.getString('instant_summary', lang)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(
          controller: _urlController,
          decoration: InputDecoration(
            hintText: LocalizationService.getString('paste_url', lang),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            prefixIcon: const Icon(Icons.link, color: Colors.redAccent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _summarizeUrl,
            style: ElevatedButton.styleFrom(
              elevation: 4,
              shadowColor: theme.primaryColor.withOpacity(0.4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, size: 20),
                const SizedBox(width: 12),
                Text(LocalizationService.getString('start_generation', lang), style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuideSection(ThemeData theme) {
    final lang = appLanguageNotifier.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LocalizationService.getString('guide', lang), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 16),
        _buildGuideStep(1, Icons.play_circle_fill, LocalizationService.getString('guide_step1', lang)),
        const Padding(
          padding: EdgeInsets.only(left: 19),
          child: SizedBox(height: 12, child: VerticalDivider(color: Colors.white12)),
        ),
        _buildGuideStep(2, Icons.share, LocalizationService.getString('guide_step2', lang)),
        const Padding(
          padding: EdgeInsets.only(left: 19),
          child: SizedBox(height: 12, child: VerticalDivider(color: Colors.white12)),
        ),
        _buildGuideStep(3, Icons.task_alt, LocalizationService.getString('guide_step3', lang)),
      ],
    );
  }

  Widget _buildGuideStep(int num, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 40, color: Colors.white24),
        const SizedBox(width: 16),
        Text(text, style: const TextStyle(fontSize: 15, color: Colors.white70)),
      ],
    );
  }

}
