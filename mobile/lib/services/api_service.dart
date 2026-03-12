import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<Map<String, dynamic>> summarizeVideo(String url, String userId,
      {String? geminiApiKey, String? groqApiKey, String? language, String? summaryDetail}) async {
    final Map<String, dynamic> body = {
      'url': url, 
      'userId': userId,
      'language': language ?? '繁體中文',
      'summaryDetail': summaryDetail ?? '精簡 (Concise)',
    };
    if (groqApiKey != null && groqApiKey.isNotEmpty) {
      body['groqApiKey'] = groqApiKey;
    }
    if (geminiApiKey != null && geminiApiKey.isNotEmpty) {
      body['geminiApiKey'] = geminiApiKey;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/summarize'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    
    if (response.statusCode == 202) {
      return jsonDecode(response.body);
    } else {
      throw Exception('啟動總結失敗: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getTaskStatus(String taskId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/v1/tasks/$taskId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('獲取狀態失敗');
    }
  }

  Future<void> sendEmail(String taskId, String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/tasks/$taskId/send-email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode != 200) {
      throw Exception('發送郵件失敗');
    }
  }
}
