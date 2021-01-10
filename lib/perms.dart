import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionSets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Scaffold scaffold = new Scaffold(
        backgroundColor: Color(0xfff7eae6),
        appBar: AppBar(
          leading: Icon(Icons.settings),
          title: Text("Permissions"),
        ),
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height,
            ),
            child: Center(
              child: ListView(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "Tap to grant permission",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ),
                Divider(
                  thickness: 3.0,
                ),
                PermissionWidget(Permission.sms, "SMS"),
                PermissionWidget(Permission.camera, "Camera"),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    onPressed: () => checkPermission(context),
                    child: Text("Next"),
                  ),
                ),
              ]),
            ),
          ),
        ));
    return scaffold;
  }
}

/// Check if required permissions are available.
/// If not then redirect to permissions page
Future checkPermission(context) async {
  final cameraPermission = await Permission.camera.isGranted;
  final smsPermission = await Permission.sms.isGranted;

  if (cameraPermission && smsPermission) {
    String currentPath = ModalRoute.of(context).settings.name;
    // if not on home then route to home
    if (currentPath != "/") Navigator.pushNamed(context, '/');
  } else {
    Navigator.pushNamed(context, '/permissions');
  }
}

/// Permission widget which displays a permission and allows users to request
/// the permissions.
class PermissionWidget extends StatefulWidget {
  /// Constructs a [PermissionWidget] for the supplied [Permission].
  const PermissionWidget(this._permission, this._permissionTitle);

  final Permission _permission;
  final String _permissionTitle;

  @override
  _PermissionState createState() =>
      _PermissionState(_permission, _permissionTitle);
}

class _PermissionState extends State<PermissionWidget> {
  _PermissionState(this._permission, this._permissionTitle);

  final Permission _permission;
  final String _permissionTitle;
  PermissionStatus _permissionStatus = PermissionStatus.undetermined;

  @override
  void initState() {
    super.initState();

    _listenForPermissionStatus();
  }

  void _listenForPermissionStatus() async {
    final status = await _permission.status;
    setState(() => _permissionStatus = status);
  }

  Icon getIcon() {
    switch (_permissionStatus) {
      case PermissionStatus.granted:
        return Icon(
          Icons.done,
          color: Colors.green,
        );
      case PermissionStatus.denied:
        return Icon(
          Icons.cancel,
          color: Colors.red,
        );
      default:
        return Icon(Icons.touch_app);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_permissionTitle),
      trailing: getIcon(),
      onTap: () {
        requestPermission(_permission);
      },
    );
  }

  void checkServiceStatus(BuildContext context, Permission permission) async {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text((await permission.status).toString()),
    ));
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();

    setState(() {
      print(status);
      _permissionStatus = status;
      print(_permissionStatus);
    });
  }
}
