// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:practice/screens/login/edit_number.dart';
import 'package:practice/screens/user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InfoView extends StatefulWidget {
  const InfoView({Key? key}) : super(key: key);

  @override
  _InfoViewState createState() => _InfoViewState();
}

class _InfoViewState extends State<InfoView> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> _logOut() async {
    final SharedPreferences prefs = await _prefs;
    prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UserInfo(),
          SizedBox(
            height: 15,
          ),
          CupertinoButton(
            color: Colors.blue,
            child: Text("登出"),
            onPressed: () {
              _logOut();
              Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(builder: (context) => EditNumber()),
                  (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
