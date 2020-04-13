import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:playstack/screens/mainscreen.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  //Register function
  _Register(String username, String email, String password) async {
    print("Intento de registro con " + username + email + password);

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> data = {
      'NombreUsuario': username,
      'Contrasenya': password,
      'Correo': email
    };

    String jsonString = jsonEncode(data);
    print("Enviando " + jsonString);

    //var jsonResponse = null;
    var response = await http.post(
        "https://playstack.azurewebsites.net/crearUsuario",
        body: jsonString);
    /*var response = await http.get(
      Uri.encodeFull("https://jsonplaceholder.typicode.com/posts"),
    );*/
    if (response.statusCode == 201) {
      /*jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        setState(() {
          _loading = false;
        });
        */
      setState(() {
        _loading = false;
      });
      sharedPreferences.setString("token", "ok");
      //print("Token es " + jsonResponse[0]['userId'].toString());
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => MainScreen()),
          (Route<dynamic> route) => false);
    } else {
      setState(() {
        _loading = false;
      });
      print(response.body);
    }
    //print("Statuscode: " + response.statusCode.toString());
    print('Response: ' + response.body);
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
                          _Register(_usernameController.text,
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
