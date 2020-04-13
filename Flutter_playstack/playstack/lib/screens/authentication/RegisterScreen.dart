import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:playstack/screens/mainscreen.dart';
import 'package:playstack/shared/Loading.dart';
import 'dart:convert';
import 'package:playstack/shared/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:toast/toast.dart';
import 'package:playstack/shared/common.dart';

class RegisterScreen extends StatefulWidget {
  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imageKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _loading = false;
  int _step = 0;
  PageController _pageController = new PageController();

  final TextEditingController _usernameController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();

  SharedPreferences sharedPreferences;

  _register(String username, String email, String password) async {
    // Se las pasa al servidor
    sharedPreferences = await SharedPreferences.getInstance();
    dynamic data = {
      'NombreUsuario': username,
      'Contrasenya': password,
      'Correo': email
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
      credentials.add(email);
      credentials.add(username);
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

  bool _canGoBack() {
    return (_step == 0);
  }

  Future<bool> _onBackPressed() {
    if (_canGoBack())
      return Future.value(true);
    else {
      setState(() {
        _step--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 400),
        curve: Curves.linear,
      );
      return Future.value(false);
    }
  }

  Widget registerButtons() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(8, 50, 8, 10),
        child: Container(
            width: 350,
            height: 40,
            child: _canGoBack()
                ? RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(15.0),
                        side: BorderSide(color: Colors.black)),
                    color: Colors.red[400],
                    onPressed: () {
                      setState(() {
                        _step++;
                      });
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );

                      // devolverá true si el formulario es válido, o falso si
                      // el formulario no es válido.
                      /*      if (_formKey.currentState.validate()) {
                  Toast.show("Loading...", context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                if (_formKey.currentState.validate()) {
                  // Si el formulario es válido, queremos mostrar un Snackbar
                  setState(() {
                    _loading = true;
                  });
                  _register(_usernameController.text, _emailController.text,
                      _passwordController.text);
                } else {
                  Toast.show("Invalid credentials", context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                }*/
                    },
                    child: Text(
                      'Next',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ))
                : Row(
                    children: <Widget>[
                      RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(15.0),
                              side: BorderSide(color: Colors.black)),
                          color: Colors.red[400],
                          onPressed: () {
                            setState(() {
                              _step--;
                            });
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            'Back',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          )),
                      RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(15.0),
                              side: BorderSide(color: Colors.black)),
                          color: Colors.red[400],
                          onPressed: () {
                            setState(() {
                              _step++;
                            });
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            'Next',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          )),
                    ],
                  )));
  }

  Widget usernameField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
              labelText: 'Username', icon: Icon(Icons.alternate_email)),
          validator: (String value) {
            if (value.length < 1)
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
        decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'example@gmail.com',
            icon: Icon(Icons.email)),
        validator: (String value) {
          if (!value.contains('@') || !value.contains('.')) {
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
        decoration:
            InputDecoration(labelText: 'Password', icon: Icon(Icons.lock)),
        obscureText: _obscureText,
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
          decoration: InputDecoration(
              labelText: 'Confirm password', icon: Icon(Icons.check_circle)),
          obscureText: _obscureText,
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
            : Column(children: <Widget>[
                logoRegister(),
                WillPopScope(
                  onWillPop: _onBackPressed,
                  child: Expanded(
                      child: PageView(
                          physics: new NeverScrollableScrollPhysics(),
                          controller: _pageController,
                          children: <Widget>[
                        Center(
                          child: Scaffold(
                            backgroundColor: Colors.transparent,
                            body: Form(
                              key: _formKey,
                              child: Center(
                                  child: ListView(
                                children: <Widget>[
                                  Center(
                                      child: Text(
                                    'Register',
                                    style: TextStyle(
                                        fontFamily: 'Circular', fontSize: 30),
                                  )),
                                  usernameField(),
                                  emailField(),
                                  passwordField(),
                                  confirmField(),
                                  FlatButton(
                                      onPressed: _toggle,
                                      child: new Text(
                                          _obscureText ? "Show" : "Hide")),
                                ],
                              )),
                            ),
                          ),
                        ),
                        Center(
                          child: Scaffold(
                              backgroundColor: Colors.transparent,
                              body: Form(
                                  key: _imageKey,
                                  child: Column(children: <Widget>[
                                    Center(
                                        child: Text(
                                      'Say Cheese!',
                                      style: TextStyle(
                                          fontFamily: 'Circular', fontSize: 30),
                                    )),
                                    Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 15, 0, 10),
                                        child: Center(
                                            child: Text(
                                                '''Add a profile picture.\nDon\'t worry, you can change it later!''',
                                                style: TextStyle(
                                                    fontFamily: 'Circular',
                                                    fontSize: 15),
                                                textAlign: TextAlign.center))),
                                    Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 30, 0, 0),
                                        child: Center(
                                          child: Container(
                                            width: 128.0,
                                            height: 128.0,
                                            child: GestureDetector(
                                              onTap: () => uploadImage(
                                                  sharedPreferences),
                                              child: ProfilePicture(),
                                            ),
                                          ),
                                        ))
                                  ]))),
                        ),
                        Center(
                            child: Scaffold(
                                body: Text(
                          'Premium (WIP)',
                          style:
                              TextStyle(fontFamily: 'Circular', fontSize: 30),
                        )))
                      ])),
                ),
                registerButtons(),
              ]));
  }
}
