import 'package:firebase_core/firebase_core.dart';

/// Firebase configuration for VetCare Connect
/// Generated from google-services.json and GoogleService-Info.plist
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyD_N3nJsfe6KEOkm45OwI_xBybfhwtbLP8',
      appId: '1:589310427700:android:04e6c732df2f467d020061',
      messagingSenderId: '589310427700',
      projectId: 'vetcare-connect-d3daf',
      storageBucket: 'vetcare-connect-d3daf.firebasestorage.app',
      iosBundleId: 'com.example.vetcareConnect', // Update this if you use iOS
    );
  }


  /// Android-specific Firebase options
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD_N3nJsfe6KEOkm45OwI_xBybfhwtbLP8',
    appId: '1:589310427700:android:04e6c732df2f467d020061',
    messagingSenderId: '589310427700',
    projectId: 'vetcare-connect-d3daf',
    storageBucket: 'vetcare-connect-d3daf.firebasestorage.app',
  );
}

