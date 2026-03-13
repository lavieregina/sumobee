import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can re-configure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCh-kIcOY2vOL_xtbV0jxjQMHIgWOJTerg',
    appId: '1:611110087066:android:2d84d6b17af08014dc7223',
    messagingSenderId: '611110087066',
    projectId: 'sumobee',
    storageBucket: 'sumobee.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBCHwn68IZQLnEahPccARMB4QGAnfeMiSM',
    appId: '1:611110087066:ios:cd8b4f84d946b4ffdc7223',
    messagingSenderId: '611110087066',
    projectId: 'sumobee',
    storageBucket: 'sumobee.firebasestorage.app',
    iosBundleId: 'com.lavieregina.sumobee',
  );
}
