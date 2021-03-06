// ignore_for_file: prefer_const_constructors, prefer_typing_uninitialized_variables, no_logic_in_create_state

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:core';

import 'package:practice/home_page.dart';

class TakeMeterNew extends StatefulWidget {
  const TakeMeterNew({Key? key, this.number}) : super(key: key);
  final number;

  @override
  _TakeMeterNewState createState() => _TakeMeterNewState(number);
}

class _TakeMeterNewState extends State<TakeMeterNew> {
  var firebaseUser = FirebaseAuth.instance.currentUser;

  final number;
  double selectedValue = 1;
  late String meterSize;
  late String meterYear;
  late int meterNumber;
  var list = [];

  String _format(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime).toString();
  }

  _TakeMeterNewState(this.number);

  @override
  void initState() {
    _initFlowMeterNumber();
    super.initState();
  }

  void _initFlowMeterNumber() {
    var temp;
    if (number != null) {
      meterSize = number.toString().substring(0, 1);
      meterYear = number.toString().substring(1, 4);
      meterNumber = int.parse(number.toString().substring(4));
      temp = meterSize + meterYear + " - " + meterNumber.toString();
      list.clear();
      list.add(temp.toString());
    }
  }

  void _uploadWaterMeterInfo() async {
    for (var item in list) {
      final snapShot = await FirebaseFirestore.instance
          .collection('waterMeter')
          .doc(item)
          .get();

      if (snapShot.exists) {
        _showDialogOfOverlay(context, item);
      } else {
        FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser!.uid)
            .collection('waterMeter')
            .doc(item)
            .set({"date": _format(DateTime.now())});

        FirebaseFirestore.instance.collection('waterMeter').doc(item).set({
          "owner": firebaseUser!.displayName,
          "ownerId": firebaseUser!.uid,
          "date": _format(DateTime.now())
        });
      }
    }
  }
  // ??????????????? -

  void _updateWaterMeterInfo(String number) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser!.uid)
        .collection('waterMeter')
        .doc(number)
        .set({"date": _format(DateTime.now())});

    FirebaseFirestore.instance.collection('waterMeter').doc(number).set({
      "owner": firebaseUser!.displayName,
      "ownerId": firebaseUser!.uid,
      "date": _format(DateTime.now())
    });
  }

  _showDialogOfCheck(BuildContext context, String content, String title) {
    showCupertinoDialog<void>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                  child: Text("??????"),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        CupertinoPageRoute(builder: (context) => HomePage()),
                        (route) => false);
                  },
                ),
              ],
            ));
  }
  // ??????????????? -

  _showDialogOfOverlay(BuildContext context, String number) {
    var title = "????????????";
    var content = "$number ??????????????????\n??????????????????????????????";

    showCupertinoDialog<void>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                  child: Text("??????"),
                  onPressed: () {
                    _updateWaterMeterInfo(number);
                    Navigator.of(context).pop();
                    _showDialogOfCheck(context, "??????????????????", "????????????");
                  },
                ),
                CupertinoDialogAction(
                  child: Text("??????"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  void _iterateList(int value) {
    list.clear();
    for (var i = 0; i < value; i++) {
      var _temp = meterNumber + i;
      String _temp2 = meterSize + meterYear + " - " + (_temp.toString());
      list.add(_temp2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        middle: Text("????????????"),
        trailing: GestureDetector(
          onTap: () {},
          child: TextButton(
              onPressed: () {
                _uploadWaterMeterInfo();
                _showDialogOfCheck(context, "????????????", "????????????");
                setState(() {});
              },
              child: Text(
                '??????',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              )),
        ),
        leading: GestureDetector(
          onTap: () {},
          child: CupertinoButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(builder: (context) => HomePage()),
                  (route) => false);
            },
            child: Icon(CupertinoIcons.xmark),
          ),
        ),
      ),
      child: ListView(
        children: [
          SizedBox(
            height: 50,
          ),
          Center(
            child: Text(
              "???????????????????????????????????????\n?????????????????????????????????\n?????????????????????????????????\n????????????????????????",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          CupertinoSlider(
              value: selectedValue,
              min: 1,
              max: 50,
              divisions: 49,
              onChanged: (value) {
                selectedValue = value;
                setState(() => _iterateList(selectedValue.round()));
              }),
          Center(child: Text(selectedValue.round().toString())),
          SizedBox(
            height: 50,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (var item in list)
                  Text(item,
                      style: TextStyle(
                        fontSize: 20,
                      ))
              ],
            ),
          ),
          SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }
}
