import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/shared/constants.dart';

class AccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AccessOption(),
    );
  }
}

class AccessOption extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 50, 0, 30),
              child: Container(
                  height: 200.0,
                  width: 200.0,
                  child: Image.asset('lib/assets/Photos/logo_name.png')),
            ),
            Text(
              'Login',
              style: TextStyle(fontFamily: 'Circular', fontSize: 30),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
              child: TextFormField(
                  decoration: myTextInputDecoration.copyWith(
                      hintText: 'Email or username')),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
              child: TextFormField(
                decoration:
                    myTextInputDecoration.copyWith(hintText: 'Password'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 20),
              child: Container(
                  width: 300,
                  height: 40,
                  child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(15.0),
                          side: BorderSide(color: Colors.black)),
                      color: Colors.red[400],
                      onPressed: () {
                        // TODO: cambiar esto cuando tengamos conexion con base de datos
                        Navigator.pushNamed(context, 'mainscreen');
                      },
                      child: Text(
                        'Log in',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ))),
            ),
            Row(children: <Widget>[
              Expanded(
                  child: Divider(
                endIndent: 15,
                indent: 15,
              )),
              Text("OR"),
              Expanded(
                  child: Divider(
                endIndent: 15,
                indent: 15,
              )),
            ]),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 30, 8, 10),
              child: Container(
                  width: 300,
                  height: 60,
                  child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(15.0),
                          side: BorderSide(color: Colors.black)),
                      onPressed: () {
                        // TODO: cambiar esto cuando tengamos conexion con base de datos
                        Navigator.pushNamed(context, 'mainscreen');
                      },
                      color: Colors.red[500],
                      child: Text(
                        'Register',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ))),
            ),
          ],
        ),
      ),
    );
  }
}
