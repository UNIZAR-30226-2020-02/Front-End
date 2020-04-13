import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:playstack/shared/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSettings extends StatefulWidget {
  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  // Imagen por defecto
  var defaultImagePath =
      'https://i7.pngguru.com/preview/753/432/885/user-profile-2018-in-sight-user-conference-expo-business-default-business.jpg';

  var imagePath;

  //Campos a modificar
  String _username;
  String _email;
  String _password;
  String _repeatPassword;
  bool _obscureText = true;
  bool _loading = true;

  // Para comprartir variables entre pantallas
  SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    getFieldValues();
  }

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> getFieldValues() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      List<String> credentials = sharedPreferences.getStringList('Credentials');
      // Coge el username
      _username = credentials.elementAt(0);
      _email = credentials.elementAt(1);
      _password = credentials.elementAt(2);
      _loading = false;
    });
  }

  Widget updateButton() {
    return Container(
      height: 50.0,
      width: MediaQuery.of(context).size.width / 2,
      child: RaisedButton(
        onPressed: () {},
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

  Widget changeProfilePhotoButton() {
    return Container(
      height: 30.0,
      width: MediaQuery.of(context).size.width / 3,
      child: RaisedButton(
        onPressed: () {},
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
            body: ListView(children: <Widget>[
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
                        child: CircleAvatar(
                            //backgroundColor: Color(0xFF191414),
                            radius: 60,
                            backgroundImage: (imagePath != null)
                                ? NetworkImage(imagePath)
                                : NetworkImage(defaultImagePath)),
                      ),
                      changeProfilePhotoButton(),
                      SizedBox(
                        height: 15,
                      ),
                      TextField(
                          controller: TextEditingController.fromValue(
                              new TextEditingValue(
                                  text: _username,
                                  selection: new TextSelection.collapsed(
                                      offset: _username.length))),
                          onChanged: (val) {
                            _username = val;
                          },
                          decoration: InputDecoration(
                              icon: Icon(Icons.person), labelText: 'Username')),
                      SizedBox(height: 10),
                      // Campo para el email
                      TextField(
                          controller: TextEditingController.fromValue(
                              new TextEditingValue(
                                  text: _email,
                                  selection: new TextSelection.collapsed(
                                      offset: _email.length))),
                          onChanged: (val) {
                            _email = val;
                          },
                          decoration: InputDecoration(
                              icon: Icon(Icons.email), labelText: 'Email')),
                      SizedBox(height: 15),
                      // Campo para la contraseña
                      TextField(
                          obscureText: _obscureText,
                          controller: TextEditingController.fromValue(
                              new TextEditingValue(
                                  text: _password,
                                  selection: new TextSelection.collapsed(
                                      offset: _password.length))),
                          onChanged: (val) {
                            _password = val;
                          },
                          decoration: InputDecoration(
                              icon: Icon(Icons.lock), labelText: 'Password')),
                      TextField(
                          obscureText: _obscureText,
                          controller: TextEditingController.fromValue(
                              new TextEditingValue(
                                  text: _password,
                                  selection: new TextSelection.collapsed(
                                      offset: _password.length))),
                          onChanged: (val) {
                            _repeatPassword = val;
                          },
                          decoration: InputDecoration(
                              icon: Icon(Icons.check),
                              labelText: 'Repeat password')),
                      FlatButton(
                          onPressed: _toggle,
                          child: new Text(_obscureText ? "Show" : "Hide")),
                      SizedBox(height: 15),
                      updateButton()
                    ],
                  ),
                ),
              ),
            ]),
          );
  }
}
