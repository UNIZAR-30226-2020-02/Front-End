import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:playstack/screens/mainscreen.dart';
import 'package:playstack/shared/Loading.dart';
import 'dart:convert';
import 'package:playstack/shared/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:playstack/shared/Loading.dart';

class RegisterScreen extends StatefulWidget {
  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<RegisterScreen> {

  final _formKey = GlobalKey<FormState>();
  String pass = null;
  bool _obscureText = true;
  bool _loading = false;
  String _email, _password;

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  bool usernameNotTaken(String username){
    return true;
  }
  bool emailNotTaken(String username){
    return true;
  }

  Widget logoRegister(){
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 40, 0, 40),
          child: Container(
            width: 64.0,
            height: 64.0,
            child: Image.asset('lib/assets/Photos/logo.png'),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
          child: Container(
            width: 260.0,
            height: 34.0,
            child: Image.asset('lib/assets/Photos/name.png'),
          ),
        ),
      ],
    );
  }
  // Check if its a digit
  bool isDigit(String s) =>
      "0".compareTo(s[0]) <= 0 && "9".compareTo(s[0]) >= 0;

  bool passwordIsSafe(String password) {
    bool isSafe = false;
    var char = '';

    if (password.length >= 8) {
      for (int i = 0; i < password.length; i++) {
        char = password.substring(i, i + 1);
        if (!isDigit(char)) {
          if (char == char.toUpperCase()) {
            isSafe = true;
          }
        }
      }
    }
    return isSafe;
  }

  Widget registerButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 5, 8, 10),
      child: Container(
          width: 350,
          height: 40,
          child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(15.0),
                  side: BorderSide(color: Colors.black)),
              color: Colors.red[400],
              onPressed: () {
                // devolverá true si el formulario es válido, o falso si
                // el formulario no es válido.
                if (_formKey.currentState.validate()) {
                  // Si el formulario es válido, queremos mostrar un Snackbar
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('Loading...')));
                } else if (!_formKey.currentState.validate()) {
                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text('Invalid credentials')));
                }
              },
              child: Text(
                'Register',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ))),
    );
  }

Widget usernameField(){
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
    child: TextFormField(
        decoration: myTextInputDecoration.copyWith(
            labelText: 'Username',
            icon: Icon(Icons.account_circle)),
        validator: (String value) {
          if(value == null)
            return '''Must provide a username''';
          else if (!usernameNotTaken(value))
            return '''The username you provided is already being used, please choose a new one and try again''';
          else
            return null;
        }
    ),
  );
}

Widget emailField(){
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
    child: TextFormField(
      decoration: myTextInputDecoration.copyWith(
          labelText: 'Email',
          hintText: 'example@gmail.com',
          icon: Icon(Icons.email)),
      validator: (String value) {
        if (!value.contains('@')) {
          return 'Please enter a valid email';
        } else {
          return null;
        }
      },
    ),
  );
}

Widget passwordField(){
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
    child: TextFormField(
      decoration: myTextInputDecoration.copyWith(
          labelText: 'Password',
          icon: Icon(Icons.lock)),
      obscureText: true,
      validator: (val) {
        if (passwordIsSafe(val)) {
          pass = val;
          return null;
        } else {
          return '''Please enter a valid password with at least one upper case letter and 8 characters''';
        }
      },
    ),
  );
}

Widget confirmField(){
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
    child: TextFormField(
        decoration: myTextInputDecoration.copyWith(
            labelText: 'Confirm password',
            icon: Icon(Icons.check_circle)),
        obscureText: true,
        validator: (val) {
          if(pass == val){
            return null;
          }
          else{
            return '''Passwords are not the same''';
          }
        }
    ),
  );
}
  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.red[900], Colors.grey[900], Colors.grey[900]],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),
    child: _loading? Center( child: Loading() ) :
     Scaffold(

      body:Form(
        key:_formKey,
        child: Center(
            child: ListView(
              children: <Widget>[
                logoRegister(),
                usernameField(),
                emailField(),
                passwordField(),
                confirmField(),
                registerButton(),

              ],
            )),
      ),
    ),
    );

  }
}
