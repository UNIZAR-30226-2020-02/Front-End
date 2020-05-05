import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: SpinKitCubeGrid(
          color: Colors.red[600],
          size: 50.0,
        ),
      ),
    );
  }
}

class LoadingSongs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      width: MediaQuery.of(context).size.width / 2,
      color: Colors.transparent,
      child: Center(
        child: SpinKitFadingFour(
          color: Colors.red[600],
          size: 50.0,
        ),
      ),
    );
  }
}
