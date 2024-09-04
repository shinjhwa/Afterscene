// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyAKXEWeGvff2CFonTPwlOD5EiLZ_U3UGqU',
    appId: '1:352328975783:web:4fa1de8dbdf81df5d06282',
    messagingSenderId: '352328975783',
    projectId: 'afterscene-b4652',
    authDomain: 'afterscene-b4652.firebaseapp.com',
    storageBucket: 'afterscene-b4652.appspot.com',
    measurementId: 'G-FBPN6QGGW4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC9Dt_-Ys_F4EnF-pnRXaixSMBMIapXQac',
    appId: '1:352328975783:android:503c3b7c1c8adb82d06282',
    messagingSenderId: '352328975783',
    projectId: 'afterscene-b4652',
    storageBucket: 'afterscene-b4652.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBXYOLPEj0BRTgfKpFihl1JYBk5PViV0Ng',
    appId: '1:352328975783:ios:0f931f4d9adfb01fd06282',
    messagingSenderId: '352328975783',
    projectId: 'afterscene-b4652',
    storageBucket: 'afterscene-b4652.appspot.com',
    iosBundleId: 'com.example.afterscene',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBXYOLPEj0BRTgfKpFihl1JYBk5PViV0Ng',
    appId: '1:352328975783:ios:0f931f4d9adfb01fd06282',
    messagingSenderId: '352328975783',
    projectId: 'afterscene-b4652',
    storageBucket: 'afterscene-b4652.appspot.com',
    iosBundleId: 'com.example.afterscene',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAKXEWeGvff2CFonTPwlOD5EiLZ_U3UGqU',
    appId: '1:352328975783:web:5adb3c1d3f0a899fd06282',
    messagingSenderId: '352328975783',
    projectId: 'afterscene-b4652',
    authDomain: 'afterscene-b4652.firebaseapp.com',
    storageBucket: 'afterscene-b4652.appspot.com',
    measurementId: 'G-M3P4XK0EK4',
  );
}
