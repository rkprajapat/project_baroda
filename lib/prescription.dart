import 'package:flutter/material.dart';

import 'medicine.dart';

class Prescription {
  final String id;
  final String filePath;
  final int frequencyDays;
  List<Medicine> medicines;
  bool isActive;
  final DateTime createdAt;
  final DateTime modifiedAt;

  Prescription(
      {this.id,
      this.filePath,
      this.frequencyDays,
      this.medicines,
      this.isActive,
      this.createdAt,
      this.modifiedAt});

  Prescription.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        filePath = json['filePath'],
        frequencyDays = json['frequencyDays'],
        isActive = json['isActive'],
        createdAt = json['createdAt'],
        modifiedAt = json['modifiedAt'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'filePath': filePath,
        'frequencyDays': frequencyDays,
        'isActive': isActive,
        'createdAt': createdAt,
        'modifiedAt': modifiedAt,
        'medicines': medicines.map((i) => i.toJson()).toList()
      };
} // Prescription Class

//View that shows all available prescriptions
class PrescriptionView extends StatefulWidget {
  @override
  _PrescriptionViewState createState() => _PrescriptionViewState();
}

class _PrescriptionViewState extends State<PrescriptionView> {
  ScrollController _controller = new ScrollController();
  List<Prescription> prescriptions = [];

  // Delete a prescription
  void deletePrescription(int index) {
    setState(() {
      prescriptions.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments;
    // TODO - remove below code as all prescriptions
    // should be loaded from DB
    if (args != null) {
      setState(() {
        prescriptions.add(args);
      });
    }

    final Scaffold scaffold = new Scaffold(
      backgroundColor: Color(0xfff7eae6),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Prescriptions'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
            ),
            onPressed: () => Navigator.pushNamed(context, '/userDetails'),
          )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(8.0),
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
          child: Scrollbar(
            child: ListView.separated(
              controller: _controller,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: prescriptions.length,
              itemBuilder: (context, i) {
                return new PrescriptionCard(
                  prescription: prescriptions[i],
                  index: i,
                  onDelete: () => deletePrescription(i),
                );
              },
              separatorBuilder: (context, i) {
                return Divider(
                  color: Color(0xffb83005),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/PrescriptionDetails');
        },
        child: Icon(Icons.add),
      ),
    );
    return scaffold;
  }
}

typedef OnDelete();

///
/// Prescription Card
///
class PrescriptionCard extends StatelessWidget {
  final Prescription prescription;
  final int index;
  final OnDelete onDelete;

  PrescriptionCard({this.prescription, this.index, this.onDelete});

  @override
  Widget build(BuildContext context) {
    ///
    /// Redirects to Prescription details screen
    ///
    void showDetails(Prescription prep) {
      Navigator.pushNamed(context, '/PrescriptionDetails', arguments: prep);
    }

    return Center(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            (index + 1).toString(),
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xffb83005),
        ),
        title: Text("Every " + prescription.frequencyDays.toString() + " Days"),
        subtitle: prescription.medicines.length > 0
            ? Text("Total " +
                prescription.medicines.length.toString() +
                " Medicine")
            : null,
        trailing: Icon(Icons.keyboard_arrow_right),
        onTap: () => showDetails(prescription),
        contentPadding: EdgeInsets.all(8.0),
        dense: false,
      ),
    );
  }
}
