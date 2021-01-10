import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

/// check if user is logged in
Future<bool> isUserLoggedIn() async {
  _firebaseAuth.authStateChanges().listen((User user) {
    if (user != null) {
      return true;
    }
  });
  return false;
}

///
///Starting route for users
///
String initialRoute() {
  if (_firebaseAuth.currentUser != null) {
    return "/prescriptions";
  }
  return "/";
}
