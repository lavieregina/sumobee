import 'package:flutter_test/flutter_test.dart';
import 'package:sumobee/services/sharing_service.dart';

void main() {
  test('SharingService parses valid YouTube URL', () {
    const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
    final service = SharingService();
    // 假設 SharingService 有一個驗證網址的方法
    expect(service.isValidYoutubeUrl(url), isTrue);
  });

  test('SharingService rejects invalid URL', () {
    const url = 'https://google.com';
    final service = SharingService();
    expect(service.isValidYoutubeUrl(url), isFalse);
  });
}
