// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class CheckIn extends StatelessWidget {
  const CheckIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? phNumber = FirebaseAuth.instance.currentUser!.phoneNumber;
    String? user = FirebaseAuth.instance.currentUser!.displayName;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("員工簽到"),
      ),
      child: ListView(
        // crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset('assets/images/YuCheng.png',
                width: 200.0, height: 200.0),
          ),
          Center(
            child: Column(
              children: [
                Text(
                  "$user  你好！\t上下班請記得簽到！",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text("登錄號碼  $phNumber"),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: Stream(),
            padding: EdgeInsets.all(10),
          ),
        ],
      ),
    );
  }
}

class Stream extends StatefulWidget {
  const Stream({Key? key}) : super(key: key);

  @override
  _StreamState createState() => _StreamState();
}

class _StreamState extends State<Stream> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late bool isCheckInAction = false;
  late bool isCheckOutAction = false;
  bool isWorkingTime = false;
  late String _timeString;
  late String _workingAlert = "";

  var firebaseUser = FirebaseAuth.instance.currentUser;

  String checkInTime = "";
  String checkOutTime = "";

  @override
  void initState() {
    getData();
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getStream());
    super.initState();
  }

  void getData() async {
    final SharedPreferences prefs = await _prefs;
    // prefs.setBool("isCheckOutAction", false);
    // prefs.setBool("isCheckInAction", true);

    isCheckInAction = prefs.getBool("isCheckInAction")!;
    isCheckOutAction = prefs.getBool("isCheckOutAction")!;
  }

  // Check in upload to firebase
  void _setCheckInTime() async {
    final DateTime now = DateTime.now();

    final snapShot = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser!.uid)
        .collection('checkTime')
        .doc(_formatDocName(DateTime.now()))
        .get();

    if (now.hour.toInt() >= 7 && now.hour.toInt() < 19) {
      if (snapShot.exists) {
        _showDialogOfCheck(context, "今天已經簽到了！", "無法重複簽到");
      } else {
        FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser!.uid)
            .collection('checkTime')
            .doc(_formatDocName(DateTime.now()))
            .set({"check_in_time": _formatDocContent(DateTime.now())});
        _showDialogOfCheck(context, _formatDateTime(DateTime.now()), "簽到成功");
      }
    } else {
      _showDialogOfCheck(context, "非工作時段！", "無法簽到");
    }
  }

  // Check out upload to firebase
  void _setCheckOutTime() async {
    final snapShot = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser!.uid)
        .collection('checkTime')
        .doc(_formatDocName(DateTime.now()))
        .get();

    if (snapShot.exists) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser!.uid)
          .collection('checkTime')
          .doc(_formatDocName(DateTime.now()))
          .update({"check_out_time": _formatDocContent(DateTime.now())});
      _showDialogOfCheck(context, _formatDateTime(DateTime.now()), "簽退成功");
    } else {
      _showDialogOfCheck(context, "今天尚未簽到！", "無法進行簽退");
    }
  }

  // show dialog
  _showDialogOfCheck(BuildContext context, String content, String title) {
    showCupertinoDialog<void>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                  child: Text("確定"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _timeString,
          style: TextStyle(fontSize: 25),
        ),
        SizedBox(
          height: 15,
        ),
        CupertinoButton.filled(
            child: Text("簽到"),
            onPressed: isCheckInAction
                ? () {
                    // Do something check in with
                    setState(() {
                      isCheckInAction = false;
                      isCheckOutAction = true;
                      _setCheckInTime();
                      print("Check-in pressed");
                    });
                  }
                : null),
        SizedBox(
          height: 10,
        ),
        CupertinoButton.filled(
            child: Text("簽退"),
            onPressed: isCheckOutAction
                ? () {
                    // Do something check out with
                    setState(() {
                      isCheckOutAction = false;
                      _setCheckOutTime();
                      print("Check-out pressed");
                    });
                  }
                : null),
        SizedBox(
          height: 10,
        ),
        Text(
          _workingAlert,
          style: TextStyle(color: Colors.red.withOpacity(0.9), fontSize: 15),
        ),
      ],
    );
  }

  // 實時更新
  void _getStream() async {
    final SharedPreferences prefs = await _prefs;
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);

    setState(() {
      _timeString = formattedDateTime;
      //上班時間 7:00
      if (now.hour.toInt() >= 7) {
        //下班時間 19:00
        if (now.hour.toInt() < 19) {
          isWorkingTime = true;
          if (isCheckOutAction == false) {
            isCheckInAction = true;
          }
        }
      } else {
        isWorkingTime = false;
        isCheckInAction = false;
      }
      //時間內true/false, 時間內false/true, 超過時間false/true, 超過時間false/false
      _workingAlert = isWorkingTime ? "請務必注意施工安全" : "非工作時段";
      prefs.setBool("isCheckInAction", isCheckInAction);
      prefs.setBool("isCheckOutAction", isCheckOutAction);

      isCheckInAction = prefs.getBool("isCheckInAction")!;
      isCheckOutAction = prefs.getBool("isCheckOutAction")!;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy/MM/dd HH:mm:ss').format(dateTime);
  }

  String _formatDocName(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime).toString();
  }

  String _formatDocContent(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime).toString();
  }
}
