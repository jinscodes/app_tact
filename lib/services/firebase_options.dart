import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static final String? _webApiKey = dotenv.env['FIREBASE_WEB_API_KEY'];
  static final String? _androidApiKey = dotenv.env['FIREBASE_ANDROID_API_KEY'];
  static final String? _iosApiKey = dotenv.env['FIREBASE_IOS_API_KEY'];
  static final String? _webappId = dotenv.env['FIREBASE_WEB_APP_ID'];
  static final String? _windowsAppId = dotenv.env['FIREBASE_WINDOWS_APP_ID'];
  static final String? _androidAppId = dotenv.env['FIREBASE_ANDROID_APP_ID'];
  static final String? _iosAppId = dotenv.env['FIREBASE_IOS_APP_ID'];
  static final String? _msgSenderId =
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'];
  static final String? _webMeasurementId =
      dotenv.env['FIREBASE_WEB_MEASUREMENT_ID'];
  static final String? _windowsMeasurementId =
      dotenv.env['FIREBASE_WINDOWS_MEASUREMENT_ID'];
  static final String? _iosClientId = dotenv.env['FIREBASE_IOS_CLIENT_ID'];

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static final FirebaseOptions web = FirebaseOptions(
    apiKey: _webApiKey ?? '',
    appId: _webappId ?? '',
    messagingSenderId: _msgSenderId ?? '',
    projectId: 'app-sticky-note',
    authDomain: 'app-sticky-note.firebaseapp.com',
    storageBucket: 'app-sticky-note.firebasestorage.app',
    measurementId: _webMeasurementId ?? '',
  );

  static FirebaseOptions windows = FirebaseOptions(
    apiKey: _webApiKey ?? '',
    appId: _windowsAppId ?? '',
    messagingSenderId: _msgSenderId ?? '',
    projectId: 'app-sticky-note',
    authDomain: 'app-sticky-note.firebaseapp.com',
    storageBucket: 'app-sticky-note.firebasestorage.app',
    measurementId: _windowsMeasurementId ?? '',
  );

  static FirebaseOptions android = FirebaseOptions(
    apiKey: _androidApiKey ?? '',
    appId: _androidAppId ?? '',
    messagingSenderId: _msgSenderId ?? '',
    projectId: 'app-sticky-note',
    storageBucket: 'app-sticky-note.firebasestorage.app',
  );

  static FirebaseOptions ios = FirebaseOptions(
    apiKey: _iosApiKey ?? '',
    appId: _iosAppId ?? '',
    messagingSenderId: _msgSenderId ?? '',
    projectId: 'app-sticky-note',
    storageBucket: 'app-sticky-note.firebasestorage.app',
    iosClientId: _iosClientId ?? '',
    iosBundleId: 'com.jay.appStickerNote',
  );

  static FirebaseOptions macos = FirebaseOptions(
    apiKey: _iosApiKey ?? '',
    appId: _iosAppId ?? '',
    messagingSenderId: _msgSenderId ?? '',
    projectId: 'app-sticky-note',
    storageBucket: 'app-sticky-note.firebasestorage.app',
    iosClientId: _iosClientId ?? '',
    iosBundleId: 'com.jay.appStickerNote',
  );
}
