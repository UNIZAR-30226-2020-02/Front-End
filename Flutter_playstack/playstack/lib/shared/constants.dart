import 'package:flutter/material.dart';

const myTextInputDecoration = InputDecoration(
  fillColor: Colors.grey,
  filled: true,
  contentPadding: EdgeInsets.all(12.0),
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 0.2),
      borderRadius: BorderRadius.all(Radius.elliptical(30, 30))),
  focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 0.2),
      borderRadius: BorderRadius.all(Radius.elliptical(30, 30))),
);
