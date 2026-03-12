import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'dart:async';

class SharingService {
  late StreamSubscription _intentDataStreamSubscription;
  List<SharedFile>? _sharedFiles;

  bool isValidYoutubeUrl(String url) {
    final regex = RegExp(
      r'^(https?://)?(www\.)?(youtube\.com|youtu\.be)/.+$',
      caseSensitive: false,
    );
    return regex.hasMatch(url);
  }

  void initSharing(Function(String) onUrlReceived) {
    // 處理 App 在背景時接收到的分享
    _intentDataStreamSubscription = FlutterSharingIntent.instance
        .getMediaStream()
        .listen((List<SharedFile> value) {
      if (value.isNotEmpty && value.first.value != null) {
        final url = value.first.value!;
        if (isValidYoutubeUrl(url)) {
          onUrlReceived(url);
        }
      }
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // 處理 App 冷啟動時接收到的分享
    FlutterSharingIntent.instance.getInitialSharing().then((List<SharedFile> value) {
      if (value.isNotEmpty && value.first.value != null) {
        final url = value.first.value!;
        if (isValidYoutubeUrl(url)) {
          onUrlReceived(url);
        }
      }
    });
  }

  void dispose() {
    _intentDataStreamSubscription.cancel();
  }
}
