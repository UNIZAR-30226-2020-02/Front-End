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
                  height: 130.0,
                  width: 300.0,
                  child: Row(
                    children: <Widget>[
                      Container(
                          height: 90,
                          width: 150,
                          child: Image.asset('lib/assets/Photos/logo.png')),
                      Container(
                          width: 150,
                          child: Image.asset('lib/assets/Photos/name.png'))
                    ],
                  )),
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
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  width: 300,
                  height: 40,
                  child: RaisedButton(
                      disabledColor: Colors.red[400],
                      onPressed: null,
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
            ])
          ],
        ),
      ),
    );
  }
}

class AccessOptions extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new AccessOptionsState();
  }
}

class AccessOptionsState extends State<AccessOptions> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[800],
      child: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 30),
            RaisedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Login(), fullscreenDialog: true));
              },
              textColor: Colors.white,
              padding: const EdgeInsets.all(0.0),
              child: Container(
                width: 200,
                height: 50,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      Colors.redAccent,
                      Colors.redAccent,
                      Colors.redAccent
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(10.0),
                child: const Text(
                  'Login',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            const SizedBox(height: 30),
            RaisedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Register(),
                        fullscreenDialog: true));
              },
              textColor: Colors.white,
              padding: const EdgeInsets.all(0.0),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      Colors.indigo,
                      Colors.blueAccent,
                      Colors.blue,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(10.0),
                child: const Text('Register', style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Login extends StatefulWidget {
  @override
  LoginState createState() {
    return LoginState();
  }
}

// Define una clase de estado correspondiente. Esta clase contendrá los datos
// relacionados con el formulario.
class LoginState extends State<Login> {
  // Crea una clave global que identificará de manera única el widget Form
  // y nos permita validar el formulario
  //
  // Nota: Esto es un `GlobalKey<FormState>`, no un GlobalKey<MyCustomFormState>!
  final _formKey = GlobalKey<FormState>();
  // Initially password is obscure
  bool _obscureText = true;
  String _email, _password;

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Cree un widget Form usando el _formKey que creamos anteriormente
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: new Center(
              child: new Text('PlayStack',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.indigo)))),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.alternate_email, color: Colors.indigo),
                hintText: 'example@gmail.com',
                labelText: 'Email *',
                //font:
              ),
              onSaved: (val) => _email = val,
              validator: (String value) {
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                } else {
                  return '';
                }
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: 'Password',
                  icon: const Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: const Icon(Icons.lock))),
              validator: (val) => val.length < 6
                  ? 'Looks like your password is too short.'
                  : null,
              onSaved: (val) => _password = val,
              obscureText: _obscureText,
            ),
            new FlatButton(
                onPressed: _toggle,
                child: new Text(_obscureText ? "Show" : "Hide")),
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
        ),
      ),
    );
  }
}

class Register extends StatefulWidget {
  @override
  RegisterState createState() {
    return RegisterState();
  }
}

// Define una clase de estado correspondiente. Esta clase contendrá los datos
// relacionados con el formulario.
class RegisterState extends State<Register> {
  // Crea una clave global que identificará de manera única el widget Form
  // y nos permita validar el formulario
  //
  // Nota: Esto es un `GlobalKey<FormState>`, no un GlobalKey<MyCustomFormState>!
  final _formKey = GlobalKey<FormState>();
  // Initially password is obscure
  bool _obscureText = true;
  String _email, _username, _password;

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Cree un widget Form usando el _formKey que creamos anteriormente
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: new Center(
              child: new Text('PlayStack',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.indigo)))),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.alternate_email, color: Colors.indigo),
                hintText: 'user@gmail.com',
                labelText: 'Email *',
                //font:
              ),
              onChanged: (val) => _email = val,
              validator: (String value) {
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                } else {
                  return '';
                }
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.person, color: Colors.indigo),
                hintText: 'Manuel1234',
                labelText: 'Username *',
                //font:
              ),
              onChanged: (val) => _username = val,
              validator: (String value) {
                if (value.isEmpty) {
                  return 'Please enter a valid name';
                } else {
                  return '';
                }
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: 'Password',
                  icon: const Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: const Icon(Icons.lock))),
              validator: (val) => val.length < 6
                  ? 'Looks like your password is too short.'
                  : null,
              onChanged: (val) => _password = val,
              obscureText: _obscureText,
            ),
            new FlatButton(
                onPressed: _toggle,
                child: new Text(_obscureText ? "Show" : "Hide")),
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
        ),
      ),
    );
  }
}
