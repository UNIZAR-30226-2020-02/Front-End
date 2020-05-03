import 'package:flutter/material.dart';
import 'package:playstack/shared/common.dart';

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  Widget updateAccountTypeButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        height: 40.0,
        width: MediaQuery.of(context).size.width / 2,
        child: RaisedButton(
          onPressed: () =>
              /* Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => YourPublicProfile(true))) */
              null,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
          padding: EdgeInsets.all(0.0),
          child: Ink(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.lime[900],
                    Colors.lime[600],
                    Colors.lime[900]
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10.0)),
            child: Container(
              constraints: BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
              alignment: Alignment.center,
              child: Text(
                "Hazte Premium",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: updateAccountTypeButton(),
      backgroundColor: backgroundColor,
      appBar: AppBar(title: Text('Cuenta')),
      body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    "Nombre de usuario: ",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width / 3),
                  Text(userName, style: TextStyle(fontSize: 16))
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: <Widget>[
                  Text("Tipo de cuenta: ", style: TextStyle(fontSize: 16)),
                  SizedBox(width: MediaQuery.of(context).size.width / 3 + 6),
                  Text(kindOfAccount, style: TextStyle(fontSize: 16))
                ],
              ),
            ],
          )),
    );
  }
}
