import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sumobee/services/localization_service.dart';
import 'package:sumobee/main.dart';
import 'package:sumobee/screens/preview_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final response = await _supabase
          .from('summary_tasks')
          .select('*')
          .order('created_at', ascending: false)
          .limit(20);
      
      if (mounted) {
        setState(() {
          _tasks = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint('Error fetching history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = appLanguageNotifier.value;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalizationService.getString('history', lang), // Need to add to localization
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchHistory,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.amber))
            : _tasks.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return _buildHistoryCard(task);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_outlined, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            '尚未有摘要紀錄', 
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(dynamic task) {
    final status = task['status'];
    final bool isSuccess = status == 'success';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSuccess ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSuccess ? Icons.description_outlined : Icons.error_outline,
            color: isSuccess ? Colors.green : Colors.redAccent,
            size: 20,
          ),
        ),
        title: Text(
          task['video_url'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${task['created_at'].toString().split('T')[0]} · ${isSuccess ? '已完成' : '失敗'}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        onTap: () {
          if (isSuccess) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PreviewScreen(
                  content: task['content'] ?? '',
                  taskId: task['id'],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
