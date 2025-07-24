import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDvNj3hEPLT2HVhBEWmtGsqVSc48DPqPqM',
    appId: '1:731609511479:web:4ba490d6e6609e4e8bf1b2',
    messagingSenderId: '731609511479',
    projectId: 'app-sticky-note',
    authDomain: 'app-sticky-note.firebaseapp.com',
    storageBucket: 'app-sticky-note.firebasestorage.app',
    measurementId: 'G-4696TJ0GVL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAiuZykRwqUNdRDDahyadU2A1af66IsgM4',
    appId: '1:731609511479:android:730da4e37c98a9958bf1b2',
    messagingSenderId: '731609511479',
    projectId: 'app-sticky-note',
    storageBucket: 'app-sticky-note.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA9SEjX0-9UkRzkQ-qobf7AQy5dk4HJk0E',
    appId: '1:731609511479:ios:274eb68c630624dd8bf1b2',
    messagingSenderId: '731609511479',
    projectId: 'app-sticky-note',
    storageBucket: 'app-sticky-note.firebasestorage.app',
    iosClientId: '731609511479-rbgou9fvbi7va0hnpgodiu728fli18cl.apps.googleusercontent.com',
    iosBundleId: 'com.example.appStickerNote',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA9SEjX0-9UkRzkQ-qobf7AQy5dk4HJk0E',
    appId: '1:731609511479:ios:274eb68c630624dd8bf1b2',
    messagingSenderId: '731609511479',
    projectId: 'app-sticky-note',
    storageBucket: 'app-sticky-note.firebasestorage.app',
    iosClientId: '731609511479-rbgou9fvbi7va0hnpgodiu728fli18cl.apps.googleusercontent.com',
    iosBundleId: 'com.example.appStickerNote',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDvNj3hEPLT2HVhBEWmtGsqVSc48DPqPqM',
    appId: '1:731609511479:web:9512a6d23f10723a8bf1b2',
    messagingSenderId: '731609511479',
    projectId: 'app-sticky-note',
    authDomain: 'app-sticky-note.firebaseapp.com',
    storageBucket: 'app-sticky-note.firebasestorage.app',
    measurementId: 'G-VBCFDQRQD7',
  );

}