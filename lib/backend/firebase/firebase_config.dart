import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyBPZtbEhzY1UbzPBTmC35xzfBnaYqCYg-M",
            authDomain: "ssss-ehfczw.firebaseapp.com",
            projectId: "ssss-ehfczw",
            storageBucket: "ssss-ehfczw.firebasestorage.app",
            messagingSenderId: "609634494439",
            appId: "1:609634494439:web:d2ef92d477f1fc78f73f42"));
  } else {
    await Firebase.initializeApp();
  }
}
