import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumobee/services/localization_service.dart';
import 'package:sumobee/main.dart'; // For appLanguageNotifier

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appLanguage = '繁體中文';
  String _outputLanguage = '繁體中文';
  String _summaryDetail = '精簡 (Concise)';
  final String _version = '1.0.1 (Testing Edition)';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _appLanguage = prefs.getString('appLanguage') ?? '繁體中文';
      _outputLanguage = prefs.getString('outputLanguage') ?? '繁體中文';
      _summaryDetail = prefs.getString('summaryDetail') ?? '精簡 (Concise)';
    });
  }

  Future<void> _saveSetting(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    setState(() {
      if (key == 'appLanguage') {
        _appLanguage = value;
        appLanguageNotifier.value = value; // Update global notifier
      }
      if (key == 'outputLanguage') _outputLanguage = value;
      if (key == 'summaryDetail') _summaryDetail = value;
    });
  }

  Future<void> _clearAllData() async {
    final lang = appLanguageNotifier.value;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationService.getString('clear_confirm_title', lang)),
        content: Text(LocalizationService.getString('clear_confirm_content', lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: Text(LocalizationService.getString('cancel', lang))
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: Text(
              LocalizationService.getString('confirm_clear', lang), 
              style: const TextStyle(color: Colors.redAccent)
            )
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocalizationService.getString('clear_success', lang)), 
          behavior: SnackBarBehavior.floating
        ),
      );
      _loadSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = appLanguageNotifier.value;
    final languages = ['繁體中文', 'English', '日本語', '한국어'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalizationService.getString('settings_title', lang), 
          style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E1E1E), Color(0xFF0F0F0F)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionTitle(LocalizationService.getString('preferences', lang)),
            _buildSettingItem(
              icon: Icons.language,
              title: LocalizationService.getString('app_language', lang),
              subtitle: _appLanguage,
              onTap: () => _showPicker(LocalizationService.getString('app_language', lang), languages, 'appLanguage', _appLanguage),
            ),
            _buildSettingItem(
              icon: Icons.auto_awesome_outlined,
              title: LocalizationService.getString('output_language', lang),
              subtitle: _outputLanguage,
              onTap: () => _showPicker(LocalizationService.getString('output_language', lang), languages, 'outputLanguage', _outputLanguage),
            ),
            _buildSettingItem(
              icon: Icons.short_text,
              title: LocalizationService.getString('summary_length', lang),
              subtitle: _summaryDetail,
              onTap: () => _showPicker(LocalizationService.getString('summary_length', lang), ['極簡 (Ultra-short)', '精簡 (Concise)', '詳細 (Detailed)'], 'summaryDetail', _summaryDetail),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(LocalizationService.getString('maintenance', lang)),
            _buildSettingItem(
              icon: Icons.delete_forever,
              title: LocalizationService.getString('clear_all_data', lang),
              subtitle: LocalizationService.getString('remove_data_desc', lang),
              color: Colors.redAccent.withOpacity(0.8),
              onTap: _clearAllData,
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(LocalizationService.getString('about', lang)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(LocalizationService.getString('version', lang), style: const TextStyle(color: Colors.white, fontSize: 16)),
              trailing: Text(_version, style: const TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.amber.withOpacity(0.7),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.amber),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        onTap: onTap,
      ),
    );
  }

  void _showPicker(String title, List<String> options, String key, String current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
            const SizedBox(height: 16),
            ...options.map((opt) => ListTile(
              title: Text(opt, style: TextStyle(color: opt == current ? Colors.amber : Colors.white)),
              trailing: opt == current ? const Icon(Icons.check, color: Colors.amber) : null,
              onTap: () {
                _saveSetting(key, opt);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }
}
