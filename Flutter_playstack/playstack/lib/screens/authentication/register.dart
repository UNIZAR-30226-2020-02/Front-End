import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  // Formkey para register form 
  final _formKey = GlobalKey<FormState>();

  // Variables globales
  bool loading = false;

  String error = '';
  String email = '';
  String password = '';
  String userName = '';

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
