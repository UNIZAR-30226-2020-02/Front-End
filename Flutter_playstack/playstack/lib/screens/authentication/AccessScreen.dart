import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:playstack/screens/MainScreen.dart';
import 'package:playstack/shared/Loading.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:playstack/shared/common.dart';
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

  // Para recuperar el correo o usuario del usuario que acaba de iniciar sesión
  Future getUserInfo(String name) async {
    var response = await http.get(
      "https://playstack.azurewebsites.net/user/get/info?NombreUsuario=$name",
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode == 200) {
      var credentials = jsonDecode(response.body);
      return credentials;
    } else {
      return "error";
    }
  }

  //Sign in function
  signIn(String mail, pass) async {
    //print("Iniciando sesion con " + mail + " y " + pass);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    dynamic data = {'NombreUsuario': mail, 'Contrasenya': pass};
    data = jsonEncode(data);
    var response = await http.post(
        "https://playstack.azurewebsites.net/user/login",
        headers: {"Content-Type": "application/json"},
        body: data);

    print("Statuscode " + response.statusCode.toString());
    if (response.statusCode == 200) {
      print("usuario registrado, comprobando otro campo...");
      var credentials = await getUserInfo(mail);
      print("Username set to " + credentials['NombreUsuario'].toString());
      userName = credentials['NombreUsuario'];
      userEmail = credentials['Correo'];
      sharedPreferences.setString("LoggedIn", 'yes');
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => MainScreen()),
          (Route<dynamic> route) => false);

      setState(() {
        _loading = false;
      });
    } else {
      if (response.statusCode == 404) {
        setState(() {
          _loading = false;
          Toast.show(languageStrings['userNotRegistered'], context,
              duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
        });
      } else {
        setState(() {
          _loading = false;
          Toast.show(languageStrings['incorrectPass'], context,
              duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
        });
      }

      print(response.body);
    }
  }

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Widget passwordFormField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 30, 10),
      child: TextFormField(
        controller: passwordController,
        decoration: InputDecoration(
            hintText: languageStrings['pass'],
            icon: Icon(Icons.lock),
            labelText: languageStrings['pass']),
        validator: (val) {
          if (val != null) {
            return null;
          } else {
            return languageStrings['passErr1'];
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
            hintText: languageStrings['emailOrUser'],
            labelText: languageStrings['emailOrUser']),
        validator: (String value) {
          if (value.length < 1) {
            return languageStrings['usernameErr1'];
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
            onPressed: () {
              if (_formKey.currentState.validate()) {
                setState(() {
                  _loading = true;
                });
                signIn(emailOrUsernameController.text, passwordController.text);

                /* signInPrueba(
                    emailOrUsernameController.text, passwordController.text); */
              }
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(80.0),
                side: BorderSide(color: Colors.black)),
            padding: EdgeInsets.all(0.0),
            child: Ink(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red[700], Colors.red[300], Colors.red[700]],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20.0)),
              child: Container(
                constraints: BoxConstraints(maxWidth: 350.0, minHeight: 50.0),
                alignment: Alignment.center,
                child: Text(
                  languageStrings['login'],
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ),
        ));
  }

  Widget registerButton() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
        child: Container(
          width: 350,
          height: 60,
          child: RaisedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('Register');
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(80.0)),
            padding: EdgeInsets.all(0.0),
            child: Ink(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red[900], Colors.red[500], Colors.red[900]],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20.0)),
              child: Container(
                  constraints: BoxConstraints(maxWidth: 350.0, minHeight: 50.0),
                  alignment: Alignment.center,
                  child: Text(
                    languageStrings['register'],
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  )),
            ),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    setState(() => _loading = true);
    Future<String> futureString = loadLanguagesString();
    futureString.then((value) {
      languageStrings = jsonDecode(value);
      print("Loaded ${languageStrings['language']}");
      setState(() => _loading = false);
    });
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
                        //Logo Image
                        logoFigure(),
                        //Form fields
                        emailFormField(),
                        passwordFormField(),
                        FlatButton(
                            onPressed: _toggle,
                            child: new Text(_obscureText
                                ? languageStrings['show']
                                : languageStrings['hide'])),
                        loginButton(),
                        Row(children: <Widget>[
                          Expanded(
                              child: Divider(
                            color: Colors.grey,
                            endIndent: 15,
                            indent: 15,
                          )),
                          Text(languageStrings['or']),
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

/* signInPrueba(String email, pass) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {'NombreUsuario': email, 'Contrasenya': pass};
    var jsonResponse = null;
    var response = await http.get(
      Uri.encodeFull("https://jsonplaceholder.typicode.com/posts"),
    );

    if (response.statusCode == 200) {
      List<String> credentials = new List();
      credentials.add(email);
      credentials.add(pass);
      jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        setState(() {
          _loading = false;
        });
        sharedPreferences.setString("LoggedIn", 'yes');
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
  } */
