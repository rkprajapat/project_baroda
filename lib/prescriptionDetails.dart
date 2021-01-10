import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_baroda/medicine.dart';
import 'package:project_baroda/prescription.dart';

/**
 */ ////////////////////////////////////

class PrescriptionDetails extends StatefulWidget {
  @override
  _PrescriptionDetailsState createState() => _PrescriptionDetailsState();
}

class _PrescriptionDetailsState extends State<PrescriptionDetails> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  var freqController = TextEditingController();
  ScrollController _controller = new ScrollController();
  bool isActive = true;
  File _image;
  bool _imageSelected = false;
  final picker = ImagePicker();

  List<Medicine> medicines = [];
  List<MedicineForm> medicineForms = [];

  //function to take the picture
  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _imageSelected = true;
      } else {
        print('No image selected.');
      }
    });
  }

  // Delete medicines
  void medicineDelete(int index) {
    setState(() {
      medicines.removeAt(index);
    });
  }

  //add Medicine
  void addMedicine() {
    setState(() {
      medicines.add(Medicine(
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
        quantity: 1,
      ));
      var length = medicines.length;
      print(length);
    });
  }

  @override
  Widget build(BuildContext context) {
    medicineForms.clear();

    final args = ModalRoute.of(context).settings.arguments;
    print(args);
    // TODO: - remove below code as all prescriptions
    // should be loaded from DB
    if (args != null) {
      setState(() {
        Prescription existingPrescription = args;
        if (existingPrescription.filePath != null) {
          _image = File(existingPrescription.filePath);
          _imageSelected = true;
        }
        if (existingPrescription.medicines.length > 0) {
          medicines = existingPrescription.medicines;
        }
        freqController.text = existingPrescription.frequencyDays.toString();
      });
    }

    final Scaffold scaffold = new Scaffold(
        key: _scaffoldKey,
        backgroundColor: Color(0xfff7eae6),
        appBar: AppBar(
          title: Text('Prescription Details'),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.all(8.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 8.0,
                  ),
                  RaisedButton(
                    elevation: 4.0,
                    onPressed: getImage,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Prescription Image'),
                        Icon(Icons.add_a_photo),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: _imageSelected
                        ? MediaQuery.of(context).size.height / 5
                        : 50.0,
                    child: _imageSelected
                        ? Image.file(_image)
                        : Text('No image selected'),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextFormField(
                    controller: freqController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10.0),
                      labelText: 'Frequency Days',
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Color(0xffb83005),
                      )),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Invalid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text('Active'),
                      Switch(
                        value: isActive,
                        onChanged: (newValue) {
                          setState(() {
                            isActive = newValue;
                          });
                          print(isActive);

                          print(isActive);
                        },
                        activeTrackColor: Colors.green,
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Scrollbar(
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        controller: _controller,
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        shrinkWrap: true,
                        itemCount: medicines.length,
                        itemBuilder: (context, i) {
                          return new MedicineForm(
                            medicine: medicines[i],
                            onDelete: () => medicineDelete(i),
                            index: i,
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Container(
                      alignment: Alignment.topRight,
                      child: FlatButton(
                        child: Text('Add Medicines (Optional)'),
                        onPressed: addMedicine,
                      )),
                  SizedBox(
                    height: 8.0,
                  ),
                  Wrap(
                    spacing: 10.0,
                    children: [
                      RaisedButton(
                        onPressed: savePrescription,
                        child: Text('Submit'),
                      ),
                      RaisedButton(
                        onPressed: null,
                        child: Text("Delete"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
    return scaffold;
  }

  // Saves a prescription
  void savePrescription() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      if (!_imageSelected && medicines.length == 0) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
              'Error: Either a prescription image or medicines need to be added'),
        ));
      } else {
        Prescription prescription = Prescription(
            filePath: _imageSelected ? _image.path : null,
            frequencyDays: int.parse(freqController.text),
            isActive: isActive,
            medicines: medicines,
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now());

        print(prescription.toJson());

        // TODO: Remove after DB integration
        Navigator.pushNamed(context, '/prescriptions', arguments: prescription);
      }
    } else {
      print('invalid form');
    }
  }
}
