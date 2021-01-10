import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:project_baroda/perms.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();

  String _message = '';
  String _verificationId;
  bool isSMSSent = false;

  @override
  void initState() {
    super.initState();
    // check phone permission before login
    checkPermission(context);
    // if existing user then redirect to prescriptions
    _auth.authStateChanges().listen((User user) {
      if (user != null) {
        Navigator.pushNamed(context, '/prescriptions');
      }
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _phoneNumberController.dispose();
    _smsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Scaffold scaffold = new Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xfff0d5cd),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        'Welcome to ProBar',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0),
                      ),
                      TextFormField(
                        controller: _phoneNumberController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(8.0),
                          labelText: 'Phone Number',
                          labelStyle: TextStyle(color: Colors.black),
                          prefixText: '+91',
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xffb83005))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [LengthLimitingTextInputFormatter(10)],
                        validator: (value) {
                          if (value.length < 10) {
                            return 'Invalid phone number';
                          }
                          return null;
                        },
                      ),
                      RaisedButton(
                        onPressed: () async {
                          _formKey.currentState.validate();
                          if (_formKey.currentState.validate()) {
                            isSMSSent = true;
                            _verifyPhoneNumber();
                          }
                        },
                        child: Text('Send SMS'),
                      ),
                      TextFormField(
                        enabled: isSMSSent,
                        controller: _smsController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(8.0),
                          labelText: 'SMS OTP',
                          labelStyle: TextStyle(color: Colors.black),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xffb83005))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        validator: (value) {
                          if (value.length < 6) {
                            return "Invalid SMS OTP";
                          }
                          return null;
                        },
                      ),
                      RaisedButton(
                        onPressed: () async {
                          if (!isSMSSent) {
                            return null;
                          } else {
                            if (_smsController.text.length == 6) {
                              _signInWithPhoneNumber();
                            }
                          }
                        },
                        child: Text('Verify Number'),
                      ),
                      Visibility(
                        visible: _message == null ? false : true,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            _message,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      )
                    ]),
              ),
            ),
          ),
        ),
      ),
    );

    return scaffold;
  }

  ///
  ///
  /// Verify phone number
  ///
  void _verifyPhoneNumber() async {
    setState(() {
      _message = '';
    });

    PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential phoneAuthCredential) async {
      await _auth.signInWithCredential(phoneAuthCredential);
      // _scaffoldKey.currentState.showSnackBar(SnackBar(
      //   content: Text(
      //       "Phone number automatically verified and user signed in: $phoneAuthCredential"),
      // ));
    };

    PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      setState(() {
        _message =
            'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}';
      });
    };

    PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      _scaffoldKey.currentState.showSnackBar(const SnackBar(
        content: Text('Please check your phone for the verification code.'),
      ));
      _verificationId = verificationId;
    };

    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
    };

    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: "+91" + _phoneNumberController.text,
          timeout: const Duration(minutes: 5),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } catch (e) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Failed to Verify Phone Number: $e"),
      ));
    }
  }

  ///
  ///Sign in with phone
  ///
  void _signInWithPhoneNumber() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _smsController.text,
      );
      final UserCredential userCreds =
          await _auth.signInWithCredential(credential);
      if (userCreds.additionalUserInfo.isNewUser) {
        // if a new user then redirect to user details page
        Navigator.pushNamed(context, '/userDetails',
            arguments: _phoneNumberController.text);
      } else {
        // if existing user then redirect to prescriptions
        Navigator.pushNamed(context, '/prescriptions');
      }
    } catch (e) {
      print(e);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Failed to sign in"),
      ));
    }
  }
}
