import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_baroda/helperFunctions.dart';

import 'package:project_baroda/login.dart';
import 'package:project_baroda/perms.dart';
import 'package:project_baroda/prescriptionDetails.dart';
import 'package:project_baroda/user.dart';
import 'package:project_baroda/prescription.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: initialRoute(),
      routes: {
        "/": (context) => Login(),
        "/permissions": (context) => PermissionSets(),
        "/userDetails": (context) => AddUser(),
        "/prescriptions": (context) => PrescriptionView(),
        "/PrescriptionDetails": (context) => PrescriptionDetails(),
      },
      theme: ThemeData(
          primaryColor: Color(0xffb83005),
          accentColor: Color(0xffb83005),
          fontFamily: "Georgia",
          textTheme: TextTheme(
            headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
            bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          ),
          buttonTheme: ButtonThemeData(
            buttonColor: Color(0xffb83005),
            textTheme: ButtonTextTheme.primary,
          )),
    );
  }
}
