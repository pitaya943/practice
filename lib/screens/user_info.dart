// ignore_for_file: prefer_final_fields, prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({Key? key}) : super(key: key);

  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String name = "";
  late bool loginState = false;
  late String phone = "";
  late String uid = "";
  late bool isCheckInAction = false;
  late bool isCheckOutAction = false;

  @override
  void initState() {
    _infoOfUser();
    super.initState();
  }

  Future<void> _infoOfUser() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      loginState = prefs.getBool("login_state")!;
      name = prefs.getString("user")!;
      phone = prefs.getString("user_number")!;
      uid = prefs.getString("user_uid")!;
      isCheckInAction = prefs.getBool("isCheckInAction")!;
      isCheckOutAction = prefs.getBool("isCheckOutAction")!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("使用者名稱 : $name"),
          Text("使用者電話 : $phone"),
          Text("使用者 Uid : $uid"),
          Text("使用者登入狀態 : ${loginState.toString()}"),
          Text("簽到action狀態 : ${isCheckInAction.toString()}"),
          Text("簽退action狀態 : ${isCheckOutAction.toString()}"),
          CupertinoButton(
              child: Icon(CupertinoIcons.refresh),
              onPressed: () => _infoOfUser()),
        ],
      ),
    );
  }
}
