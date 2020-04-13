import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      _username = sharedPreferences.getString('username');
      _email = sharedPreferences.getString('email');
      _password = sharedPreferences.getString('password');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                RaisedButton(
                  onPressed: null,
                  child: Text('Cambiar imagen'),
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
                        icon: Icon(Icons.check), labelText: 'Repeat password')),
                FlatButton(
                    onPressed: _toggle,
                    child: new Text(_obscureText ? "Show" : "Hide")),
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width / 2,
                  child: RaisedButton(
                    disabledColor: Colors.white,
                    focusColor: Colors.green,
                    onPressed: null,
                    child: Text(
                      'Actualizar',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
