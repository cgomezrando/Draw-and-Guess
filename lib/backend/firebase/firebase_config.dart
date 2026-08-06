import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyD13Nk6348phKj5jxG3QpO7i4CjqPlzHtQ",
            authDomain: "draw-and-guess-29e50.firebaseapp.com",
            projectId: "draw-and-guess-29e50",
            storageBucket: "draw-and-guess-29e50.firebasestorage.app",
            messagingSenderId: "440664175018",
            appId: "1:440664175018:web:d60054000e53bca52efbd3",
            measurementId: "G-P5L3SXBC8C"));
  } else {
    await Firebase.initializeApp();
  }
}
