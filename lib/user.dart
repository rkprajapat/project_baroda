import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:project_baroda/prescription.dart';

// User data model
class AppUser {
  final String id;
  final String name;
  final int phone;
  final String address;
  List<Prescription> prescriptions;
  bool isActive;
  bool isAdmin;
  final DateTime dateOfBirth;
  final String gender;
  final DateTime createdAt;
  DateTime modifiedAt;

  AppUser(
      {this.id,
      this.name,
      this.phone,
      this.address,
      this.prescriptions,
      this.isActive,
      this.isAdmin,
      this.dateOfBirth,
      this.gender,
      this.createdAt,
      this.modifiedAt});

  // Convert to Object from json
  AppUser.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        phone = int.parse(json['phone']),
        address = json['address'],
        dateOfBirth = json['dateOfBirth'],
        gender = json['gender'],
        createdAt = json['createdAt'],
        modifiedAt = json['modifiedAt'];

  //Convert to JSON. To be JSON Encoded later
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone.toString(),
        'address': address,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'createdAt': createdAt,
        'modifiedAt': modifiedAt
      };
} // User class

class AddUser extends StatefulWidget {
  @override
  _AddUserState createState() => _AddUserState();
}

// Add User Widget
// This widget collects user details for first time setup
class _AddUserState extends State<AddUser> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final dobController = TextEditingController();
  String genderValue = '';

  @override
  Widget build(BuildContext context) {
    //read phone number from previous login screen
    int phoneNumber = int.parse(ModalRoute.of(context).settings.arguments);
    final dtFormat = new DateFormat("d MMMM y");
    DateTime selectedDate = new DateTime.utc(1982, 04, 10);

    //This function provided a date for date picker
    Future<void> _selectDate(BuildContext context) async {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(1980, 8),
          lastDate: DateTime(2101));
      if (picked != null && picked != selectedDate) {
        selectedDate = picked;
        dobController.text = dtFormat.format(picked);
      }
    }

    final Scaffold addUser = new Scaffold(
      backgroundColor: Color(0xfff7eae6),
      appBar: AppBar(
        title: Text('Please provide Details'),
      ),
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    TextFormField(
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10.0),
                        labelText: 'Name',
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffb83005))),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                      ),
                      keyboardType: TextInputType.name,
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
                        contentPadding: EdgeInsets.all(10.0),
                        labelText: 'Address',
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffb83005))),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                      ),
                      keyboardType: TextInputType.multiline,
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
                        contentPadding: EdgeInsets.all(10.0),
                        labelText: 'Date of Birth',
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffb83005))),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                      ),
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        _selectDate(context);
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
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10.0),
                          labelText: 'Gender',
                          labelStyle: TextStyle(color: Colors.black),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xffb83005))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                        ),
                        items: <String>['Male', 'Female']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        validator: (value) {
                          if (genderValue.isEmpty) {
                            return 'Invalid gender';
                          }
                          return null;
                        },
                        onChanged: (String newValue) {
                          setState(() {
                            print(newValue);
                            genderValue = newValue;
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
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();

                              final currentUser = new AppUser(
                                  name: nameController.text,
                                  phone: phoneNumber,
                                  address: addressController.text,
                                  isActive: false,
                                  isAdmin: false,
                                  dateOfBirth: selectedDate,
                                  gender: genderValue,
                                  createdAt: new DateTime.now());

                              // print(jsonEncode(currentUser.toJson()));
                              Navigator.pushNamed(context, '/prescriptions');
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
      ),
    );

    return addUser;
  }
} // AddUser Widget
