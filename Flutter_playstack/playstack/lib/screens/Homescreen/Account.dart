import 'package:flutter/material.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/common.dart';
import 'package:toast/toast.dart';

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  void becomePremium() async {
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

  Widget updateAccountTypeButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        height: 40.0,
        width: MediaQuery.of(context).size.width / 2,
        child: RaisedButton(
          onPressed: () => becomePremium(),
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

  void checkIfAccepted() async {
    Toast.show("Actualizando...", context,
        gravity: Toast.CENTER, backgroundColor: Colors.grey[700]);
    bool res = await checkAccountType();
    if (res) {
      Toast.show("Actualizando correctamente", context,
          gravity: Toast.CENTER, backgroundColor: Colors.grey[700]);

      setState(() {});
    } else {
      Toast.show("Error actualizando", context,
          gravity: Toast.CENTER, backgroundColor: Colors.grey[700]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          accountType == "No Premium" ? updateAccountTypeButton() : Text(''),
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => homeIndex.value = 2), //Settings,
        title: Text('Cuenta'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.refresh), onPressed: () => checkIfAccepted())
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Nombre de usuario: ",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: Text(userName, style: TextStyle(fontSize: 16)))
                  ],
                ),
              ),
              SizedBox(height: 15),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: <Widget>[
                    Expanded(
                        flex: 2,
                        child: Text("Tipo de cuenta: ",
                            style: TextStyle(fontSize: 16))),
                    Expanded(
                        flex: 1,
                        child:
                            Text(accountType, style: TextStyle(fontSize: 16)))
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
