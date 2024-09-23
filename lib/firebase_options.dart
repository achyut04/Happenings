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
    apiKey: 'AIzaSyCMqcjy2cmjztK6BNveAvopxWExoUckJ_c',
    appId: '1:712765466361:web:5adff32d8b58bd815f2428',
    messagingSenderId: '712765466361',
    projectId: 'happeningsdb-7979c',
    authDomain: 'happeningsdb-7979c.firebaseapp.com',
    storageBucket: 'happeningsdb-7979c.appspot.com',
    measurementId: 'G-9Q6LEKBHTB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBLNERzXQj0brI3aiIr16DLXHAoy_Ggujo',
    appId: '1:712765466361:android:f8d8c6bda51028545f2428',
    messagingSenderId: '712765466361',
    projectId: 'happeningsdb-7979c',
    storageBucket: 'happeningsdb-7979c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDuSbuea-T3_0PYBPiS9Yo9kNoVtzgWUe0',
    appId: '1:712765466361:ios:e954c22e90cb6f5b5f2428',
    messagingSenderId: '712765466361',
    projectId: 'happeningsdb-7979c',
    storageBucket: 'happeningsdb-7979c.appspot.com',
    iosBundleId: 'com.example.myApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDuSbuea-T3_0PYBPiS9Yo9kNoVtzgWUe0',
    appId: '1:712765466361:ios:e954c22e90cb6f5b5f2428',
    messagingSenderId: '712765466361',
    projectId: 'happeningsdb-7979c',
    storageBucket: 'happeningsdb-7979c.appspot.com',
    iosBundleId: 'com.example.myApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCMqcjy2cmjztK6BNveAvopxWExoUckJ_c',
    appId: '1:712765466361:web:d11ea82dff1226855f2428',
    messagingSenderId: '712765466361',
    projectId: 'happeningsdb-7979c',
    authDomain: 'happeningsdb-7979c.firebaseapp.com',
    storageBucket: 'happeningsdb-7979c.appspot.com',
    measurementId: 'G-QM3LZCKQ5W',
  );
}