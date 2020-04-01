import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/shared/constants.dart';

class RegisterScreen extends StatefulWidget {
  @override
  RegisterState createState() {
    return new RegisterState();
  }
}

class RegisterState extends State<RegisterScreen> {

  final _formKey = GlobalKey<FormState>();

  bool _obscureText = true;
  String _email, _password;

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  bool usernameNotTaken(String username){
    return true;
  }
  bool emailNotTaken(String username){
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Form(
        key:_formKey,
        child: Center(
          child: ListView(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 40, 0, 40),
                    child: Container(
                      width: 64.0,
                      height: 64.0,
                      child: Image.asset('lib/assets/Photos/logo.png'),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                    child: Container(
                      width: 260.0,
                      height: 34.0,
                      child: Image.asset('lib/assets/Photos/name.png'),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: TextFormField(
                    decoration: myTextInputDecoration.copyWith(
                        labelText: 'Username'),
                    validator: (String value) {
                      if(usernameNotTaken(value))
                        return '';
                      else
                        return '''The username you provided is already being used, please choose a new one and try again''';
                    }
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: TextFormField(
                    decoration: myTextInputDecoration.copyWith(
                        labelText: 'Email',
                        hintText: 'example@gmail.com')
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: TextFormField(
                    decoration: myTextInputDecoration.copyWith(
                        labelText: 'Password')
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: TextFormField(
                    decoration: myTextInputDecoration.copyWith(
                        labelText: 'Confirm password')
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  onPressed: () {
                    // devolverá true si el formulario es válido, o falso si
                    // el formulario no es válido.
                    if (_formKey.currentState.validate()) {
                      // Si el formulario es válido, queremos mostrar un Snackbar
                      Scaffold.of(context)
                          .showSnackBar(SnackBar(content: Text('Loading...')));
                    } else if (!_formKey.currentState.validate()) {
                      Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text('Invalid credentials')));
                    }
                  },
                  child: Text('Access'),
                ),
              ),
            ],
          )),
      ),
    );
  }
}
