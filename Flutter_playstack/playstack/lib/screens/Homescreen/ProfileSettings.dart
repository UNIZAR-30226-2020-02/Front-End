import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:playstack/shared/common.dart';
import 'package:playstack/shared/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSettings extends StatefulWidget {
  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  //SnackBars
  final snackBarUpdatingPhoto = SnackBar(
      content: Text(
        'Actualizando foto de perfil...',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.grey[700]);
  final snackBarPhotoUpdated = SnackBar(
      content: Text(
        'Foto de perfil actualizada!',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.grey[700]);
  final snackBarUpdatingUsername = SnackBar(
      content: Text(
        'Actualizando nombre de usuario...',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.grey[700]);
  final snackBarUsernameUpdated = SnackBar(
      content: Text(
        'Nombre de usuario actualizado!',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.grey[700]);

  // Local Variables
  String _username;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
  }

  Widget changeProfilePhotoButton(BuildContext context) {
    return Container(
      height: 30.0,
      width: MediaQuery.of(context).size.width / 3,
      child: RaisedButton(
        onPressed: () async {
          Scaffold.of(context).showSnackBar(snackBarUpdatingPhoto);
          await uploadImage();
          await getProfilePhoto();
          Scaffold.of(context).showSnackBar(snackBarPhotoUpdated);

          setState(() {});
        },
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
        padding: EdgeInsets.all(0.0),
        child: Ink(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[800], Colors.grey[700], Colors.grey[800]],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            constraints: BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
            alignment: Alignment.center,
            child: Text(
              "Cambiar imagen",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget updateButton(BuildContext context) {
    return Container(
      height: 50.0,
      width: MediaQuery.of(context).size.width / 2,
      child: RaisedButton(
        onPressed: () async {
          Scaffold.of(context).showSnackBar(snackBarUpdatingUsername);
          await updateUsername(_username);

          Scaffold.of(context).showSnackBar(snackBarUsernameUpdated);
        },
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
        padding: EdgeInsets.all(0.0),
        child: Ink(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[800], Colors.grey[700], Colors.grey[800]],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            constraints: BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
            alignment: Alignment.center,
            child: Text(
              "Actualizar",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
            backgroundColor: Color(0xFF191414),
            appBar: AppBar(
              centerTitle: true,
              title: Text("Configuración"),
            ),
            body: Builder(
              builder: (BuildContext context) {
                return ListView(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Perfil de usuario',
                            style: TextStyle(fontSize: 20),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ProfilePicture()),
                          changeProfilePhotoButton(context),
                          SizedBox(
                            height: 15,
                          ),
                          TextField(
                              controller: TextEditingController.fromValue(
                                  new TextEditingValue(
                                      text: userName,
                                      selection: new TextSelection.collapsed(
                                          offset: userName.length))),
                              onChanged: (val) {
                                _username = val;
                              },
                              decoration: InputDecoration(
                                  icon: Icon(Icons.person),
                                  labelText: 'Username')),
                          SizedBox(height: 20),
                          // Campo para el email

                          SizedBox(height: 15),
                          // Campo para la contraseña

                          SizedBox(height: 15),
                          //Boton de actualizar
                          updateButton(context),
                        ],
                      ),
                    ),
                  ),
                ]);
              },
            ),
          );
  }
}
