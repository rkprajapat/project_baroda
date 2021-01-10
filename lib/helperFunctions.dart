import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

/// check if user is logged in
Future<bool> isUserLoggedIn() async {
  try {
    _firebaseAuth.authStateChanges().listen((User user) {
      if (user != null) {
        return true;
      }
    });
  } catch (e) {
    print(e);
  }
  return false;
}

///
///Starting route for users
///
String initialRoute() {
  try {
    isUserLoggedIn().then((value) {
      if (value) {
        print("value " + _firebaseAuth.currentUser.toString());
        return "/prescriptions";
      } else {
        return "/";
      }
    });
  } catch (e) {
    print(e);
  }

  return "/";
}

///
/// Sign out user
///
Future<void> signOut(BuildContext context) async {
  try {
    context.showLoaderOverlay();
    await _firebaseAuth.signOut();
    Navigator.pushNamed(context, "/");
    context.hideLoaderOverlay();
  } catch (e) {
    print(e);
  }
}
