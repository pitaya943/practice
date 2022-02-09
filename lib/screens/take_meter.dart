// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:practice/screens/flow_meter_check.dart';

class TakeMeter extends StatefulWidget {
  const TakeMeter({Key? key}) : super(key: key);

  @override
  _TakeMeterState createState() => _TakeMeterState();
}

class _TakeMeterState extends State<TakeMeter> {
  var firebaseUser = FirebaseAuth.instance.currentUser;

  late int _sizeIndex = 0;
  late int _yearIndex = 0;
  late TextEditingController _textStart;
  late TextEditingController _textEnd;
  final waterMeterYear = [
    "106",
    "107",
    "108",
    "109",
    "110",
    "111",
    "112",
  ];
  final waterMeterSize = [
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K"
  ];

  String _format(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime).toString();
  }

  @override
  void initState() {
    _textStart = TextEditingController(text: "");
    _textEnd = TextEditingController(text: "");
    super.initState();
  }

  void _showSizePicker(BuildContext ctx) {
    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => SizedBox(
              // width: 300,
              height: 150,
              child: CupertinoPicker(
                backgroundColor: Colors.white,
                itemExtent: 30,
                scrollController: FixedExtentScrollController(initialItem: 5),
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  Text(waterMeterSize[0]),
                  Text(waterMeterSize[1]),
                  Text(waterMeterSize[2]),
                  Text(waterMeterSize[3]),
                  Text(waterMeterSize[4]),
                  Text(waterMeterSize[5]),
                  Text(waterMeterSize[6]),
                  Text(waterMeterSize[7]),
                  Text(waterMeterSize[8]),
                  Text(waterMeterSize[9]),
                  Text(waterMeterSize[10]),
                ],
                onSelectedItemChanged: (value) {
                  setState(() {
                    _sizeIndex = value;
                  });
                },
              ),
            ));
  }

  void _showYearPicker(BuildContext ctx) {
    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => SizedBox(
              // width: 300,
              height: 150,
              child: CupertinoPicker(
                backgroundColor: Colors.white,
                itemExtent: 30,
                scrollController: FixedExtentScrollController(initialItem: 3),
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  Text(waterMeterYear[0]),
                  Text(waterMeterYear[1]),
                  Text(waterMeterYear[2]),
                  Text(waterMeterYear[3]),
                  Text(waterMeterYear[4]),
                  Text(waterMeterYear[5]),
                  Text(waterMeterYear[6]),
                ],
                onSelectedItemChanged: (value) {
                  setState(() {
                    _yearIndex = value;
                  });
                },
              ),
            ));
  }

  void _uploadWaterMeterInfo() async {
    var _loop = _textEnd.text == ""
        ? 0
        : (int.parse(_textEnd.text) - int.parse(_textStart.text));
    var _index =
        "${waterMeterSize[_sizeIndex]}${waterMeterYear[_yearIndex]} - ";
    var _num = int.parse(_textStart.text);

    for (var i = _loop; i >= 0; i--, _num++) {
      final snapShot = await FirebaseFirestore.instance
          .collection('waterMeter')
          .doc("$_index$_num")
          .get();

      if (snapShot.exists) {
        _showDialogOfOverlay(context, _index, _num);
      } else {
        FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser!.uid)
            .collection('waterMeter')
            .doc("$_index$_num")
            .set({"date": _format(DateTime.now())});

        FirebaseFirestore.instance
            .collection('waterMeter')
            .doc("$_index$_num")
            .set({
          "owner": firebaseUser!.displayName,
          "ownerId": firebaseUser!.uid,
          "date": _format(DateTime.now())
        });
      }
    }
  }

  void _updateWaterMeterInfo(String index, int num) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser!.uid)
        .collection('waterMeter')
        .doc("$index$num")
        .set({"date": _format(DateTime.now())});

    FirebaseFirestore.instance.collection('waterMeter').doc("$index$num").set({
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
                  child: Text("確定"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  _showDialogOfOverlay(BuildContext context, String index, int num) {
    var title = "重複領表";
    var content = "$index$num 已被領取過了\n請問是否要重複領取？";

    showCupertinoDialog<void>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                  child: Text("確定"),
                  onPressed: () {
                    _updateWaterMeterInfo(index, num);
                    Navigator.of(context).pop();
                    _showDialogOfCheck(context, "重複領取成功", "上傳成功");
                  },
                ),
                CupertinoDialogAction(
                  child: Text("取消"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        middle: Text("領表登記"),
        leading: GestureDetector(
          onTap: () {},
          child: TextButton(
              onPressed: () {
                Navigator.push(context,
                    CupertinoPageRoute(builder: (context) => FlowMeterCheck()));
              },
              child: Text(
                '查看',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              )),
        ),
        trailing: GestureDetector(
          onTap: () {},
          child: TextButton(
              onPressed: () {
                _uploadWaterMeterInfo();
                _showDialogOfCheck(
                    context,
                    "已領取\n${waterMeterSize[_sizeIndex]}${waterMeterYear[_yearIndex]} - ${_textStart.text} ~ ${waterMeterSize[_sizeIndex]}${waterMeterYear[_yearIndex]} - ${_textEnd.text}",
                    "上傳成功");
                setState(() {
                  _textStart = TextEditingController(text: "");
                  _textEnd = TextEditingController(text: "");
                });
              },
              child: Text(
                '上傳',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              )),
        ),
      ),
      child: ListView(
        children: [
          SizedBox(
            height: 50,
          ),
          Center(
              child: Column(
            children: const [
              Text(
                "請輸入要領取的表號",
                style: TextStyle(fontSize: 30),
              ),
              Text(
                "如果只領取單顆",
                style: TextStyle(fontSize: 30),
              ),
              Text(
                "就不用輸入末號",
                style: TextStyle(fontSize: 30),
              ),
            ],
          )),
          SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                child: CupertinoButton(
                  child: Text(
                    waterMeterSize[_sizeIndex],
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                  onPressed: () => _showSizePicker(context),
                ),
              ),
              SizedBox(
                width: 100,
                child: CupertinoButton(
                  child: Text(
                    waterMeterYear[_yearIndex],
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                  onPressed: () => _showYearPicker(context),
                ),
              ),
              SizedBox(
                width: 170,
                child: CupertinoTextField(
                  keyboardType: TextInputType.number,
                  placeholder: "請輸入起號",
                  controller: _textStart,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  maxLength: 6,
                  onChanged: (String content) {
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("~"),
              SizedBox(
                width: 170,
                child: CupertinoTextField(
                  keyboardType: TextInputType.number,
                  placeholder: "請輸入末號",
                  controller: _textEnd,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  maxLength: 6,
                  onChanged: (String content) {
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Center(
              child: Column(
            children: [
              Text(
                "將領取 ${waterMeterSize[_sizeIndex]}${waterMeterYear[_yearIndex]} - ${_textStart.text}",
                style: TextStyle(fontSize: 20),
              ),
              Text(
                "~ ${waterMeterSize[_sizeIndex]}${waterMeterYear[_yearIndex]} - ${_textEnd.text}",
                style: TextStyle(fontSize: 20),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
