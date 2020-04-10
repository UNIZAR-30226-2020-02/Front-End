import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/screens/authentication/AccessScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatelessWidget {
  SharedPreferences sharedPreferences;

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
          FlatButton(onPressed: null, child: Text('Perfil de usuario')),
          FlatButton(onPressed: null, child: Text('Cuenta')),
          FlatButton(onPressed: null, child: Text('Configuración'))
        ],
      ),
    );
  }
}

Widget _profileInfo(context) {
  return Container(
    height: MediaQuery.of(context).size.height / 5,
    child: Row(
      children: <Widget>[
        Expanded(
            flex: 1,
            child: IconButton(
                icon: Icon(CupertinoIcons.person), onPressed: () {})),
        Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Unai',
                  style: TextStyle(fontSize: 15),
                ),
                RaisedButton(onPressed: null, child: Text("Ver perfil"))
              ],
            ))
      ],
    ),
  );
}
