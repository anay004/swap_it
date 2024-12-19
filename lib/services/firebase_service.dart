import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
            'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
  static const FirebaseOptions android = FirebaseOptions(
      apiKey: 'AIzaSyBLa77YB_SqGnDPhmZiZFJXOtZZoAhaxE8',
      appId: '1:643934094477:android:086a76d2edef5878474ec4',
      messagingSenderId: '643934094477',
      projectId: 'swap-it-d4b78',
      storageBucket: 'swap-it-d4b78.firebasestorage.app',
      databaseURL:
      '');

  static const FirebaseOptions ios = FirebaseOptions(
      apiKey: 'AIzaSyBLa77YB_SqGnDPhmZiZFJXOtZZoAhaxE8',
      appId: '1:643934094477:android:086a76d2edef5878474ec4',
      messagingSenderId: '643934094477',
      projectId: 'swap-it-d4b78',
      storageBucket: 'swap-it-d4b78.firebasestorage.app',
      iosBundleId: 'com.swap.swap_it"',
      databaseURL:
      '');
}