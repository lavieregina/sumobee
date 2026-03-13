import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: _analytics);

  // 追蹤摘要開始
  static Future<void> logSummarizationStarted(String videoId) async {
    await _analytics.logEvent(
      name: 'summarization_started',
      parameters: {'video_id': videoId},
    );
  }

  // 追蹤摘要成功
  static Future<void> logSummarizationSuccess(String videoId) async {
    await _analytics.logEvent(
      name: 'summarization_success',
      parameters: {'video_id': videoId},
    );
  }

  // 追蹤摘要失敗
  static Future<void> logSummarizationError(String errorType) async {
    await _analytics.logEvent(
      name: 'summarization_error',
      parameters: {'error_type': errorType},
    );
  }

  // 追蹤語言切換
  static Future<void> logLanguageChanged(String language) async {
    await _analytics.logEvent(
      name: 'language_changed',
      parameters: {'language': language},
    );
    await _analytics.setUserProperty(name: 'app_language', value: language);
  }

  // 追蹤 API Key 更新
  static Future<void> logApiKeyUpdated() async {
    await _analytics.logEvent(name: 'api_key_updated');
    await _analytics.setUserProperty(name: 'has_custom_groq_key', value: 'true');
  }
}
