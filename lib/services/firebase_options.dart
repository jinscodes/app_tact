import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
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
        throw UnsupportedError('Linux is not supported.');
      default:
        throw UnsupportedError('Unknown platform.');
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_WEB_API_KEY'] ?? '',
        appId: dotenv.env['FIREBASE_WEB_APP_ID'] ?? '',
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
        projectId: 'app-sticky-note',
        authDomain: 'app-sticky-note.firebaseapp.com',
        storageBucket: 'app-sticky-note.firebasestorage.app',
        measurementId: dotenv.env['FIREBASE_WEB_MEASUREMENT_ID'] ?? '',
      );

  static FirebaseOptions get windows => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_WEB_API_KEY'] ?? '',
        appId: dotenv.env['FIREBASE_WINDOWS_APP_ID'] ?? '',
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
        projectId: 'app-sticky-note',
        authDomain: 'app-sticky-note.firebaseapp.com',
        storageBucket: 'app-sticky-note.firebasestorage.app',
        measurementId: dotenv.env['FIREBASE_WINDOWS_MEASUREMENT_ID'] ?? '',
      );

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? '',
        appId: dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? '',
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
        projectId: 'app-sticky-note',
        storageBucket: 'app-sticky-note.firebasestorage.app',
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_IOS_API_KEY'] ?? '',
        appId: dotenv.env['FIREBASE_IOS_APP_ID'] ?? '',
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
        projectId: 'app-sticky-note',
        storageBucket: 'app-sticky-note.firebasestorage.app',
        iosClientId: dotenv.env['FIREBASE_IOS_CLIENT_ID'] ?? '',
        iosBundleId: 'com.jay.appStickerNote',
      );

  static FirebaseOptions get macos => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_IOS_API_KEY'] ?? '',
        appId: dotenv.env['FIREBASE_IOS_APP_ID'] ?? '',
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
        projectId: 'app-sticky-note',
        storageBucket: 'app-sticky-note.firebasestorage.app',
        iosClientId: dotenv.env['FIREBASE_IOS_CLIENT_ID'] ?? '',
        iosBundleId: 'com.jay.appStickerNote',
      );
}
