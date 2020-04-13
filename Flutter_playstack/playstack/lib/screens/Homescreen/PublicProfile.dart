import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class YourPublicProfile extends StatefulWidget {
  @override
  _YourPublicProfileState createState() => _YourPublicProfileState();
}

class _YourPublicProfileState extends State<YourPublicProfile> {
  String _username;
  bool _loading = true;

  SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    getFieldValues();
  }

  Future<void> getFieldValues() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      List<String> credentials = sharedPreferences.getStringList('Credentials');
      // Coge el username
      _username = credentials.elementAt(0);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(centerTitle: true, title: Text('Tu perfil')),
            body: ListView(
              children: <Widget>[
                Center(
                    child: Column(
                  children: <Widget>[Text(_username)],
                ))
              ],
            ),
          );
  }
}
