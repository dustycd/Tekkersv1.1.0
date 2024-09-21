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
    apiKey: 'AIzaSyCM4hafdVvYm3m6T8ZrSETEAC3xhlGY9Us',
    appId: '1:167879576764:web:adeac0068ad480696054b9',
    messagingSenderId: '167879576764',
    projectId: 'tekk-d2ef1',
    authDomain: 'tekk-d2ef1.firebaseapp.com',
    storageBucket: 'tekk-d2ef1.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBUgXUeaGB3GDHgkqvugandJBf3MPBmnlk',
    appId: '1:167879576764:android:ca92cb7adde32f306054b9',
    messagingSenderId: '167879576764',
    projectId: 'tekk-d2ef1',
    storageBucket: 'tekk-d2ef1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC3YmpDjBR6gnQZXKTnopClCYMxTqYTZD8',
    appId: '1:167879576764:ios:cf4b2b266fa0acf96054b9',
    messagingSenderId: '167879576764',
    projectId: 'tekk-d2ef1',
    storageBucket: 'tekk-d2ef1.appspot.com',
    iosBundleId: 'com.example.tekkersapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC3YmpDjBR6gnQZXKTnopClCYMxTqYTZD8',
    appId: '1:167879576764:ios:cf4b2b266fa0acf96054b9',
    messagingSenderId: '167879576764',
    projectId: 'tekk-d2ef1',
    storageBucket: 'tekk-d2ef1.appspot.com',
    iosBundleId: 'com.example.tekkersapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCM4hafdVvYm3m6T8ZrSETEAC3xhlGY9Us',
    appId: '1:167879576764:web:fb573924fb4784236054b9',
    messagingSenderId: '167879576764',
    projectId: 'tekk-d2ef1',
    authDomain: 'tekk-d2ef1.firebaseapp.com',
    storageBucket: 'tekk-d2ef1.appspot.com',
  );
}