import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:playstack/screens/mainscreen.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:playstack/shared/common.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  SharedPreferences sharedPreferences;
  //Register function
  _register(String username, String mail, String password) async {
    // Se las pasa al servidor
    sharedPreferences = await SharedPreferences.getInstance();
    dynamic data = {
      'NombreUsuario': username,
      'Contrasenya': password,
      'Correo': mail
    };

    data = jsonEncode(data);

    //var jsonResponse = null;
    var response = await http.post(
        "https://playstack.azurewebsites.net/create/user",
        headers: {"Content-Type": "application/json"},
        body: data);
    if (response.statusCode == 201) {
      _loading = false;
      // Se guardan los campos para poder ser modificados posteriormente
      List<String> credentials = new List();
      credentials.add(username);
      credentials.add(mail);

      sharedPreferences.setStringList('Credentials', credentials);
      sharedPreferences.setString("LoggedIn", "ok");
      //print("Token es " + jsonResponse[0]['userId'].toString());
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => MainScreen()),
          (Route<dynamic> route) => false);
    } else {
      setState(() {
        _loading = false;
      });
    }
    print("Statuscode " + response.statusCode.toString());
  }

  bool _loading = false;

  final TextEditingController _usernameController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(hintText: 'Username'),
                    controller: _usernameController,
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: 'Email'),
                    controller: _emailController,
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: 'Password'),
                    controller: _passwordController,
                  ),
                  FlatButton(
                      onPressed: () {
                        setState(() {
                          _loading = true;
                          _register(_usernameController.text,
                              _emailController.text, _passwordController.text);
                        });
                      },
                      child: Text('Submit'))
                ],
              ),
            ),
          );
  }
}
