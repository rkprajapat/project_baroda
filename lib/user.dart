import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:project_baroda/prescription.dart';
import 'package:project_baroda/fireStoreService.dart';
import 'package:project_baroda/helperFunctions.dart' as hf;

// User data model
class AppUser {
  String uid;
  String name;
  String address;
  String phone;
  List<Prescription> prescriptions;
  bool isActive = true;
  bool isAdmin = false;
  DateTime dateOfBirth = DateTime.utc(1982, 04, 10);
  String gender;
  DateTime createdAt;
  DateTime modifiedAt;

  AppUser(
      {this.uid,
      this.name,
      this.address,
      this.phone,
      this.prescriptions,
      this.isActive,
      this.isAdmin,
      this.dateOfBirth,
      this.gender,
      this.createdAt,
      this.modifiedAt});

  // Convert to Object from json
  AppUser.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        name = json['name'],
        address = json['address'],
        phone = json['phone'],
        dateOfBirth = hf.timestampToDate(json['dateOfBirth']),
        gender = json['gender'],
        createdAt = hf.timestampToDate(json['createdAt']),
        modifiedAt = hf.timestampToDate(json['modifiedAt']);

  //Convert to JSON. To be JSON Encoded later
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'address': address,
        'phone': phone,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'createdAt': createdAt,
        'modifiedAt': modifiedAt
      };
} // User class

class UserDetails extends StatefulWidget {
  @override
  _UserDetailsState createState() => _UserDetailsState();
}

// Add User Widget
// This widget collects user details for first time setup
class _UserDetailsState extends State<UserDetails> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  Future<AppUser> _appUser;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _appUser = FireStoreService().fetchUser();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldkey,
        appBar: AppBar(
          title: Text("Account Details"),
        ),
        body: FutureBuilder(
          future: _appUser,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                if (snapshot.hasData) {
                  return _loading == false
                      ? _userDetailsWidget(snapshot.data)
                      : hf.progressLoader();
                } else {
                  return hf.progressLoader();
                }
                break;

              default:
                return Center(child: CircularProgressIndicator());
            }
          },
        ),
      );

  ///
  /// Widget builder function
  ///
  Widget _userDetailsWidget(AppUser data) {
    TextEditingController dobController =
        new TextEditingController(text: hf.dateToString(data.dateOfBirth));
    TextEditingController nameController =
        new TextEditingController(text: data.name);
    TextEditingController addressController =
        new TextEditingController(text: data.address);

// starts cursor at the end of current string
    nameController.value = TextEditingValue(
      text: data.name,
      selection: TextSelection(
          baseOffset: data.name.length, extentOffset: data.name.length),
    );

// starts cursor at the end of current string
    addressController.value = TextEditingValue(
      text: data.address,
      selection: TextSelection(
          baseOffset: data.address.length, extentOffset: data.address.length),
    );

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Form(
              key: _formKey,
              onChanged: () => {
                _formKey.currentState.validate(),
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextFormField(
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Name',
                    ),
                    keyboardType: TextInputType.name,
                    onChanged: ((String newValue) {
                      setState(() {
                        data.name = newValue;
                      });
                    }),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Invalid name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextFormField(
                    controller: addressController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Address',
                    ),
                    keyboardType: TextInputType.multiline,
                    onChanged: ((String newValue) {
                      setState(() {
                        data.address = newValue;
                      });
                    }),
                    minLines: 3,
                    maxLines: null,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Invalid address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextFormField(
                    controller: dobController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                    ),
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      hf.selectDate(context, data.dateOfBirth).then((resp) {
                        setState(() {
                          dobController.text = hf.dateToString(resp);
                          data.dateOfBirth = resp;
                        });
                      });
                    },
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (dobController.text.isEmpty) {
                        return 'Invalid date of birth';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  DropdownButtonFormField(
                      value: data.gender,
                      decoration: InputDecoration(
                        labelText: 'Gender',
                      ),
                      items: <String>['Male', 'Female']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Invalid gender';
                        }
                        return null;
                      },
                      onChanged: (String newValue) {
                        setState(() {
                          data.gender = newValue;
                        });
                      }),
                  SizedBox(
                    height: 8.0,
                  ),
                  Wrap(
                    spacing: 10.0,
                    // alignment: WrapAlignment.spaceEvenly,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            _loading = true;

                            FireStoreService()
                                .updateUser(data)
                                .then((_) => {
                                      _loading = false,
                                      Navigator.pushNamed(
                                          context, '/prescriptions'),
                                    })
                                .catchError((e) => {
                                      _loading = false,
                                      _scaffoldkey.currentState
                                          .showSnackBar(SnackBar(
                                        content: Text("Could not update user."),
                                      ))
                                    });
                          } else {
                            print('Invalid form');
                          }
                        },
                        child: Text('Next'),
                      ),
                      RaisedButton(
                        onPressed: () {
                          _formKey.currentState.reset();
                          nameController.clear();
                          addressController.clear();
                          dobController.clear();
                        },
                        child: Text('Reset'),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} // AddUser Widget
