// ignore_for_file: unnecessary_new

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:practice/screens/login/edit_number.dart';

class CoverView extends StatefulWidget {
  const CoverView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CoverViewState();
}

class _CoverViewState extends State<CoverView> {
  late Timer _timer;
  //FlutterLogoStyle _logoStyle = FlutterLogoStyle.markOnly;

  _CoverViewState() {
    _timer = new Timer(const Duration(seconds: 3), () {
      setState(() {
        //_logoStyle = FlutterLogoStyle.horizontal;
      });
      Navigator.pushReplacement(
          context, CupertinoPageRoute(builder: (context) => EditNumber()));
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/images/YuCheng.png'),
      ),
    );
  }
}
