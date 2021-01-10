import 'package:flutter/material.dart';

class Medicine {
  final String id;
  String medName;
  int quantity;
  final DateTime createdAt;
  DateTime modifiedAt;

  Medicine(
      {this.id, this.medName, this.quantity, this.createdAt, this.modifiedAt});

  Medicine.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        medName = json['medName'],
        quantity = json['quantity'],
        createdAt = json['createdAt'],
        modifiedAt = json['modifiedAt'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'medName': medName,
        'quantity': quantity,
        'createdAt': createdAt,
        'modifiedAt': modifiedAt,
      };
}

typedef OnDelete();

class MedicineForm extends StatefulWidget {
  final Medicine medicine;
  final state = _MedicineFormState();
  final OnDelete onDelete;
  final int index;

  MedicineForm({this.index, this.medicine, this.onDelete});

  @override
  _MedicineFormState createState() => state;
}

class _MedicineFormState extends State<MedicineForm> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              leading: Icon(Icons.medical_services),
              title: Text("Medicine " + (widget.index + 1).toString()),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: widget.onDelete,
                )
              ],
              backgroundColor: Color(0xffb83005).withOpacity(0.65),
            ),
            SizedBox(height: 5.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                initialValue: widget.medicine.medName,
                onSaved: (value) => widget.medicine.medName = value,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(8.0),
                  labelText: 'Medicine Name',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                    color: Color(0xffb83005),
                  )),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Invalid medicine name';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                initialValue: widget.medicine.quantity.toString(),
                onSaved: (value) => widget.medicine.quantity = int.parse(value),
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(8.0),
                  labelText: 'Quantity',
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
                  if (value.isEmpty || int.parse(value) == 0) {
                    return 'Invalid quantity';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
