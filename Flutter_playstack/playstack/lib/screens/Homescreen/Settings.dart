import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/screens/authentication/AccessScreen.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:playstack/shared/common.dart';
import 'package:image_picker/image_picker.dart';
import 'package:async/async.dart';
import 'package:path/path.dart';
import 'dart:convert';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  SharedPreferences sharedPreferences;

  List<String> credentials;

  @override
  void initState() {
    super.initState();
  }

  Widget viewPublicProfileButton(BuildContext context) {
    return Container(
      height: 35.0,
      width: MediaQuery.of(context).size.width / 3,
      child: RaisedButton(
        onPressed: () => Navigator.of(context).pushNamed('YourPublicProfile'),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
        padding: EdgeInsets.all(0.0),
        child: Ink(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange[900],
                  Colors.orange[600],
                  Colors.orange[900]
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            constraints: BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
            alignment: Alignment.center,
            child: Text(
              "Ver perfil",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileInfo(context) {
    return Container(
      height: MediaQuery.of(context).size.height / 5,
      child: Row(
        children: <Widget>[
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ProfilePicture(),
              )),
          Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      userName,
                      style: TextStyle(fontSize: 20),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: viewPublicProfileButton(context),
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FlatButton(
          onPressed: () async {
            sharedPreferences = await SharedPreferences.getInstance();
            sharedPreferences.clear();
            //sharedPreferences.commit();
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (BuildContext context) => AccessScreen()),
                (Route<dynamic> route) => false);
          },
          child: Text("Cerrar sesión")),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: Color(0xFF191414),
      appBar: AppBar(
        centerTitle: true,
        title: Text("Configuración"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _profileInfo(context),
          FlatButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed('ProfileSettings'),
              child: Text('Perfil de usuario')),
          FlatButton(onPressed: null, child: Text('Cuenta')),
          FlatButton(onPressed: null, child: Text('Configuración'))
        ],
      ),
    );
  }
}
