import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

//This function provided a date for date picker
Future<DateTime> selectDate(BuildContext context,
    [DateTime selectedDate]) async {
  final DateTime picked = await showDatePicker(
      context: context,
      initialDate:
          selectedDate == null ? new DateTime.utc(1982, 04, 10) : selectedDate,
      firstDate: DateTime(1930, 8),
      lastDate: DateTime(2101));
  if (picked != null) {
    return picked;
  }
  return DateTime.utc(1982, 04, 10);
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
    await _firebaseAuth.signOut();
    Navigator.pushNamed(context, "/");
  } catch (e) {
    print(e);
  }
}

///
/// Default date
///
String dateToString([DateTime value]) {
  final dtFormat = new DateFormat("d MMMM y");
  if (value != null) return dtFormat.format(value);

  return dtFormat.format(DateTime.now());
}

///
/// This shows the progress while processing
///
Widget progressLoader() {
  return Center(
    child: CircularProgressIndicator(),
  );
}

///
/// Timestamp to Date
///
DateTime timestampToDate(Timestamp timestamp) {
  if (timestamp == null) return null;

  return timestamp.toDate();
}
