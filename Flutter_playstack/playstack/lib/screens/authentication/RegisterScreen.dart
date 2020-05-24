import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:playstack/screens/mainscreen.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:playstack/shared/common.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

class RegisterScreen extends StatefulWidget {
  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imageKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _loading = false;
  bool _isInAsyncCall = false;
  int _step = 0;
  PageController _pageController = new PageController();
  var image;

  final TextEditingController _usernameController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _confirmController = new TextEditingController();
  bool checked = false;
  bool taken = false;

  SharedPreferences sharedPreferences;

  Future<int> _register(String username, String mail, String password) async {
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
      print("Registrado!");
      // Se guardan los campos para poder ser modificados posteriormente
      userName = username;
      print("Username with name " + userName + " created");

      userEmail = mail;
      sharedPreferences.setString("LoggedIn", "ok");
      //print("Token es " + jsonResponse[0]['userId'].toString());
    } else {
      setState(() {
        _loading = false;
      });
    }
    print("Statuscode " + response.statusCode.toString());
    return response.statusCode;
  }

  void _becomePremium() async {
    Toast.show("Enviando solicitud...", context,
        gravity: Toast.CENTER,
        duration: Toast.LENGTH_LONG,
        backgroundColor: Colors.blue[500]);
    bool res = await askToBecomePremium();
    if (res) {
      Toast.show("Solicitud de premium enviada correctamente!", context,
          gravity: Toast.CENTER,
          duration: Toast.LENGTH_LONG,
          backgroundColor: Colors.green[500]);
    } else {
      Toast.show("Error al enviar solicitud de premium", context,
          gravity: Toast.CENTER,
          duration: Toast.LENGTH_LONG,
          backgroundColor: Colors.red[500]);
    }
  }

  /* _launchPremiumURL() async {
    const url = "https://www.google.com";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  } */

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void usernameNotTaken(String username) async {
    setState(() => _isInAsyncCall = true);
    List matches = await getUsers(username);
    if (matches != null) {
      taken = matches.contains(username);
    }
    checked = true;
    setState(() => _isInAsyncCall = false);
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
    return (_step > 0);
  }

  Future<bool> _onBackPressed() {
    if (_canGoBack()) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 400),
        curve: Curves.linear,
      );
      return Future.value(false);
    } else
      return Future.value(true);
  }

  void goBack() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void goNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<bool> regiterProcess(bool requestingPremium) async {
    int statusCode = await _register(_usernameController.text,
        _emailController.text, _passwordController.text);
    switch (statusCode) {
      case 201:
        {
          await uploadImage(image);
          if (!requestingPremium) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (BuildContext context) => MainScreen()),
                (Route<dynamic> route) => false);
          }

          return true;
        }
        break;
      case 400:
        {
          _formKey.currentState.validate();
          Toast.show(languageStrings['invalidCredentials'], context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          _step = 0;
          return false;
        }
        break;
      case 406:
        {
          Toast.show(languageStrings['invalidRequest'], context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          _step = 0;
        }
        return false;

        break;
      case 500:
        {
          Toast.show(languageStrings['internalError'], context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          _step = 0;
        }
        return false;

        break;
    }
  }

  Widget registerButtons() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(8, 50, 8, 40),
        child: Container(
            width: 350,
            height: 40,
            child: _canGoBack()
                ? Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(15.0),
                                side: BorderSide(color: Colors.black)),
                            color: Colors.red[400],
                            onPressed: goBack,
                            child: Text(
                              languageStrings['back'],
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            )),
                      ),
                      Expanded(
                        child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(15.0),
                                side: BorderSide(color: Colors.black)),
                            color: Colors.red[400],
                            onPressed: () async {
                              if (_step == 2) {
                                setState(() {
                                  _loading = true;
                                });
                                regiterProcess(false);
                              } else
                                goNext();
                            },
                            child: Text(
                              languageStrings['next'],
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            )),
                      )
                    ],
                  )
                : RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(15.0),
                        side: BorderSide(color: Colors.black)),
                    color: Colors.red[400],
                    onPressed: () {
                      // devolverá true si el formulario es válido, o falso si
                      // el formulario no es válido.
                      if (_formKey.currentState.validate()) {
                        // Si el formulario es válido, queremos mostrar un Snackbar
                        goNext();
                      } else {
                        Toast.show(
                            languageStrings['invalidCredentials'], context,
                            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      }
                    },
                    child: Text(
                      languageStrings['next'],
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ))));
  }

  Widget usernameField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
              labelText: languageStrings['username'],
              icon: Icon(Icons.alternate_email),
              errorMaxLines: 3),
          validator: (String value) {
            if (value.length < 1)
              return languageStrings['usernameErr1'];
            else {
              usernameNotTaken(value);
              if (checked && taken)
                return languageStrings['usernameErr2'];
              else
                return null;
            }
          }),
    );
  }

  Widget emailField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: TextFormField(
        controller: _emailController,
        decoration: InputDecoration(
            labelText: languageStrings['email'],
            hintText: languageStrings['emailHint'],
            icon: Icon(Icons.email),
            errorMaxLines: 3),
        validator: (String value) {
          if (!value.contains('@') || !value.contains('.')) {
            return languageStrings['emailErr1'];
          } else {
            emailNotTaken(value);
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
        decoration: InputDecoration(
            labelText: languageStrings['pass'],
            icon: Icon(Icons.lock),
            errorMaxLines: 3),
        obscureText: _obscureText,
        validator: (val) {
          if (passwordIsSafe(val)) {
            return null;
          } else {
            return languageStrings['passErr1'];
          }
        },
      ),
    );
  }

  Widget confirmField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: TextFormField(
          controller: _confirmController,
          decoration: InputDecoration(
              labelText: languageStrings['confirm'],
              icon: Icon(Icons.check_circle)),
          obscureText: _obscureText,
          validator: (val) {
            if (_passwordController.text == val) {
              return null;
            } else {
              return languageStrings['confirmErr1'];
            }
          }),
    );
  }

  Widget firstPage() {
    return Center(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Form(
          key: _formKey,
          child: Center(
              child: ListView(
            children: <Widget>[
              Center(
                  child: Text(
                languageStrings['register'],
                style: TextStyle(fontFamily: 'Circular', fontSize: 30),
              )),
              usernameField(),
              emailField(),
              passwordField(),
              confirmField(),
              FlatButton(
                  onPressed: _toggle,
                  child: new Text(_obscureText
                      ? languageStrings['show']
                      : languageStrings['hide'])),
            ],
          )),
        ),
      ),
    );
  }

  Widget secondPage() {
    return _loading
        ? Loading()
        : Center(
            child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Form(
                    key: _imageKey,
                    child: Column(children: <Widget>[
                      Center(
                          child: Text(
                        languageStrings['sayCheese'],
                        style: TextStyle(fontFamily: 'Circular', fontSize: 30),
                      )),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                          child: Center(
                              child: Text(languageStrings['imageRegDesc'],
                                  style: TextStyle(
                                      fontFamily: 'Circular', fontSize: 15),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.fade))),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                          child: Center(
                            child: Container(
                              width: 128.0,
                              height: 128.0,
                              child: GestureDetector(
                                onTap: () async {
                                  image = await ImagePicker.pickImage(
                                      source: ImageSource.gallery);
                                  ProfilePictureState.setTempImage(image);
                                },
                                child: ProfilePicture(),
                              ),
                            ),
                          ))
                    ]))),
          );
  }

  TableRow premiumAdvantagesCell(Icon icon, String message) {
    return new TableRow(children: <Widget>[
      Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(children: <Widget>[
            Expanded(flex: 2, child: icon),
            Expanded(
                flex: 10,
                child: Text(message,
                    style: TextStyle(fontFamily: 'Circular', fontSize: 15),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.fade))
          ]))
    ]);
  }

  Widget thirdPage() {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView(children: <Widget>[
          Center(
              child: Text(
            languageStrings['premiumDesc1'],
            style: TextStyle(fontFamily: 'Circular', fontSize: 30),
          )),
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
              child: Center(
                  child: Text(languageStrings['premiumDesc2'],
                      style: TextStyle(fontFamily: 'Circular', fontSize: 20),
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                      textAlign: TextAlign.center))),
          Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 30, 0),
              child: Center(
                  child: Table(children: <TableRow>[
                premiumAdvantagesCell(
                    Icon(Icons.music_note), languageStrings['premiumDesc3']),
                premiumAdvantagesCell(
                    Icon(Icons.queue_music), languageStrings['premiumDesc4']),
                premiumAdvantagesCell(Icon(Icons.signal_wifi_off),
                    languageStrings['premiumDesc5']),
                premiumAdvantagesCell(
                    Icon(Icons.library_music), languageStrings['premiumDesc6']),
                premiumAdvantagesCell(
                    Icon(Icons.skip_next), languageStrings['premiumDesc7']),
              ]))),
          Padding(
              padding: const EdgeInsets.fromLTRB(70, 10, 70, 10),
              child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(15.0),
                      side: BorderSide(color: Colors.black)),
                  color: Colors.red[400],
                  onPressed: () async {
                    setState(() {
                      _loading = true;
                    });
                    bool res = await regiterProcess(true);
                    if (res) await _becomePremium();
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (BuildContext context) => MainScreen()),
                        (Route<dynamic> route) => false);
                  },
                  child: Text(languageStrings['premiumButton'],
                      style: TextStyle(fontFamily: 'Circular', fontSize: 20),
                      textAlign: TextAlign.center)))
        ]));
  }

  Widget fourthPage() {
    return Center(
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(children: <Widget>[
              Center(
                  child: Text(
                languageStrings['welcomeMessage1'],
                style: TextStyle(fontFamily: 'Circular', fontSize: 30),
              )),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                  child: Center(
                      child: Text(languageStrings['welcomeMessage2'],
                          style:
                              TextStyle(fontFamily: 'Circular', fontSize: 20),
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                          textAlign: TextAlign.center)))
            ])));
  }

  @override
  Widget build(BuildContext context) {
    _pageController.addListener(() {
      setState(() {
        _step = _pageController.page
            .floor(); //actualiza la variable cada vez que se mueve entre las paginas
      });
    });

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
                      child: ModalProgressHUD(
                    child: PageView(
                        physics: new NeverScrollableScrollPhysics(),
                        controller: _pageController,
                        children: <Widget>[
                          firstPage(),
                          secondPage(),
                          thirdPage(),
                        ]),
                    inAsyncCall: _isInAsyncCall,
                    progressIndicator: CircularProgressIndicator(),
                  )),
                ),
                registerButtons(),
              ]));
  }
}
