import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sumobee/services/api_service.dart';
import 'package:sumobee/services/localization_service.dart';
import 'package:sumobee/main.dart';

class PreviewScreen extends StatelessWidget {
  final String content;
  final String taskId;

  const PreviewScreen({
    super.key,
    required this.content,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ApiService apiService = ApiService(baseUrl: 'http://127.0.0.1:8000');
    final lang = appLanguageNotifier.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.getString('summary_preview', lang), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: Colors.amber),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: content));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(LocalizationService.getString('copy_text', lang)), behavior: SnackBarBehavior.floating),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0F0F), Color(0xFF1E1E1E)],
          ),
        ),
        child: Markdown(
          data: content,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            h1: GoogleFonts.outfit(
              color: theme.primaryColor,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
            h2: GoogleFonts.outfit(
              color: theme.primaryColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            p: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.6,
            ),
            listBullet: const TextStyle(color: Colors.amber, fontSize: 18),
            blockquote: const TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
            blockquoteDecoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: const Border(left: BorderSide(color: Colors.amber, width: 4)),
            ),
            code: GoogleFonts.firaCode(
              backgroundColor: Colors.white10,
              color: Colors.amber.shade200,
              fontSize: 14,
            ),
            horizontalRuleDecoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showEmailDialog(context, apiService),
                  icon: const Icon(Icons.email_outlined),
                  label: Text(LocalizationService.getString('send_email', lang), style: const TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {
                    // Placeholder for native share
                  },
                  icon: const Icon(Icons.share_rounded, color: Colors.white),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmailDialog(BuildContext context, ApiService apiService) {
    final controller = TextEditingController();
    final lang = appLanguageNotifier.value;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(LocalizationService.getString('send_email', lang)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('請輸入您的電子郵件地址：', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'example@gmail.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LocalizationService.getString('cancel', lang), style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = controller.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                return;
              }
              Navigator.pop(context);
              _sendEmail(context, apiService, email);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendEmail(BuildContext context, ApiService apiService, String email) async {
    final lang = appLanguageNotifier.value;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(LocalizationService.getString('summarizing', lang)), behavior: SnackBarBehavior.floating),
    );
    try {
      await apiService.sendEmail(taskId, email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ OK'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }
}
