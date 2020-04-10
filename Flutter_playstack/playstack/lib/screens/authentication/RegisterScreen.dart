import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:playstack/screens/mainscreen.dart';
import 'package:playstack/shared/Loading.dart';
import 'dart:convert';
import 'package:playstack/shared/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:toast/toast.dart';

class RegisterScreen extends StatefulWidget {
  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _loading = false;

  final TextEditingController _usernameController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();

  _register(String username, String email, String password) async {
    print("Intento de registro con " +
        username +
        " email:  " +
        email +
        ' contrasenya: ' +
        password);

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    dynamic data = {
      'NombreUsuario': username,
      'Contrasenya': password,
      'Correo': email
    };

    data = jsonEncode(data);

    //var jsonResponse = null;
    var response = await http.post(
        "https://playstack.azurewebsites.net/crearUsuario",
        headers: {"Content-Type": "application/json"},
        body: data);
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
    print("Statuscode: " + response.statusCode.toString());
  }

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  bool usernameNotTaken(String username) {
    return true;
  }

  bool emailNotTaken(String username) {
    return true;
  }

  Widget logoRegister() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 40),
      child: Row(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width / 3,
            height: 64.0,
            child: Image.asset('lib/assets/Photos/logo.png'),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 3 * 2,
            height: 34.0,
            child: Image.asset('lib/assets/Photos/name.png'),
          ),
        ],
      ),
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
                  Toast.show("Loading...", context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                  _register(_usernameController.text, _emailController.text,
                      _passwordController.text);
                } else if (!_formKey.currentState.validate()) {
                  Toast.show("Invalid credentials", context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                }
              },
              child: Text(
                'Register',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ))),
    );
  }

  Widget usernameField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: TextFormField(
          controller: _usernameController,
          decoration: myTextInputDecoration.copyWith(
              labelText: 'Username', icon: Icon(Icons.account_circle)),
          validator: (String value) {
            if (value == null)
              return '''Must provide a username''';
            else if (!usernameNotTaken(value))
              return '''The username you provided is already being used, please choose a new one and try again''';
            else
              return null;
          }),
    );
  }

  Widget emailField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: TextFormField(
        controller: _emailController,
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

  Widget passwordField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: TextFormField(
        controller: _passwordController,
        decoration: myTextInputDecoration.copyWith(
            labelText: 'Password', icon: Icon(Icons.lock)),
        obscureText: true,
        validator: (val) {
          if (passwordIsSafe(val)) {
            return null;
          } else {
            return '''Please enter a valid password with at least one upper case letter and 8 characters''';
          }
        },
      ),
    );
  }

  Widget confirmField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: TextFormField(
          decoration: myTextInputDecoration.copyWith(
              labelText: 'Confirm password', icon: Icon(Icons.check_circle)),
          obscureText: true,
          validator: (val) {
            if (_passwordController.text == val) {
              return null;
            } else {
              return '''Passwords don't match''';
            }
          }),
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
      child: _loading
          ? Center(child: Loading())
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Form(
                key: _formKey,
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
