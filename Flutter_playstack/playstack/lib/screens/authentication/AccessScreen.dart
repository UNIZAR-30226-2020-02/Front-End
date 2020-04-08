import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:playstack/screens/mainscreen.dart';
import 'package:playstack/shared/Loading.dart';
import 'dart:convert';
import 'package:playstack/shared/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class AccessScreen extends StatefulWidget {
  @override
  _AccessScreenState createState() => _AccessScreenState();
}

class _AccessScreenState extends State<AccessScreen> {
  TextEditingController emailOrUsernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _obscureText = true;
  bool _loading = false;

  //Sign in function
  signInPrueba(String email, pass) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {'NombreUsuario': email, 'Contrasenya': pass};
    var jsonResponse = null;
    var response = await http.get(
      Uri.encodeFull("https://jsonplaceholder.typicode.com/posts"),
    );

    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        setState(() {
          _loading = false;
        });
        sharedPreferences.setString(
            "token", jsonResponse[0]['userId'].toString());
        //print("Token es " + jsonResponse[0]['userId'].toString());
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => MainScreen()),
            (Route<dynamic> route) => false);
      }
    } else {
      setState(() {
        _loading = false;
      });
      print(response.body);
    }
  }

  //Sign in function
  signIn(String email, pass) async {
    print("Iniciando sesion con " + email + " y " + pass);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {'NombreUsuario': email, 'Contrasenya': pass};
    var jsonResponse = null;
    var response = await http.post("https://playstack.azurewebsites.net/Login",
        body: data);
    print("Statuscode: " +
        response.statusCode.toString() +
        " \nbody: " +
        response.body.toString());
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      setState(() async {
        _loading = false;
      });
      sharedPreferences.setString("token", 'LoggedIn');
      //print("Token es " + jsonResponse[0]['userId'].toString());
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => MainScreen()),
          (Route<dynamic> route) => false);
    } else {
      if (response.statusCode == 404) {
        setState(() {
          _loading = false;
          Toast.show("User is not registered", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
        });
      } else {
        setState(() {
          _loading = false;
          Toast.show("Incorrect password", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
        });
      }

      //print(response.body);
    }
  }

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // Check if its a digit
  bool isDigit(String s) =>
      "0".compareTo(s[0]) <= 0 && "9".compareTo(s[0]) >= 0;

  // Checks if the password is secure enough
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

  Widget passwordFormField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 30, 10),
      child: TextFormField(
        controller: passwordController,
        decoration: InputDecoration(
            hintText: 'Password',
            icon: Icon(Icons.lock),
            labelText: 'Password'),
        validator: (val) {
          if (passwordIsSafe(val)) {
            return null;
          } else {
            return "Please enter a valid password with at least one \n upper case letter and 8 characters";
          }
        },
        obscureText: _obscureText,
      ),
    );
  }

  Widget emailFormField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 30, 10),
      child: TextFormField(
        controller: emailOrUsernameController,
        enableSuggestions: true,
        decoration: InputDecoration(
            icon: Icon(Icons.mail),
            hintText: 'Email or username',
            labelText: 'Email or username'),
        validator: (String value) {
          if (value.length < 1) {
            return 'Please enter a valid email or username';
          } else {
            return null;
          }
        },
      ),
    );
  }

  Widget logoFigure() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 50, 0, 30),
      child: Container(
          height: 200.0,
          width: 200.0,
          child: Image.asset('lib/assets/Photos/logo_name.png')),
    );
  }

  Widget loginButton() {
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
                if (_formKey.currentState.validate()) {
                  setState(() {
                    _loading = true;
                  });
                  signIn(
                      emailOrUsernameController.text, passwordController.text);
                }
              },
              child: Text(
                'Log in',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ))),
    );
  }

  Widget registerButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      child: Container(
          width: 350,
          height: 60,
          child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(15.0),
                  side: BorderSide(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pushNamed("Register");
              },
              color: Colors.red[500],
              child: Text(
                'Register',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ))),
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
              body: ListView(
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        logoFigure(),
                        emailFormField(),
                        passwordFormField(),
                        FlatButton(
                            onPressed: _toggle,
                            child: new Text(_obscureText ? "Show" : "Hide")),
                        loginButton(),
                        Row(children: <Widget>[
                          Expanded(
                              child: Divider(
                            color: Colors.grey,
                            endIndent: 15,
                            indent: 15,
                          )),
                          Text("OR"),
                          Expanded(
                              child: Divider(
                            color: Colors.grey,
                            endIndent: 15,
                            indent: 15,
                          )),
                        ]),
                        registerButton()
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
