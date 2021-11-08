// ignore_for_file: prefer_const_constructors, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewBulletin extends StatefulWidget {
  const NewBulletin({Key? key, this.docId}) : super(key: key);
  final docId;

  @override
  _NewBulletinState createState() => _NewBulletinState(docId);
}

class _NewBulletinState extends State<NewBulletin> {
  late TextEditingController _textTitle;
  late TextEditingController _textContent;
  bool isUpdate = false;
  final docId;

  _NewBulletinState(this.docId);

  String _format(DateTime dateTime) {
    return DateFormat('yyyy/MM/dd HH:mm').format(dateTime);
  }

  @override
  void initState() {
    _textTitle = TextEditingController(text: "");
    _textContent = TextEditingController(text: "");

    getState();
    super.initState();
  }

  void getState() async {
    await FirebaseFirestore.instance
        .collection("bulletin")
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (docId.toString() == doc.id.toString()) {
          setState(() {
            isUpdate = true;
          });
        }
      }
    });

    if (isUpdate) {
      FirebaseFirestore.instance
          .collection('bulletin')
          .doc(docId)
          .get()
          .then((data) {
        _textTitle.text = data.get("title");
        _textContent.text = data.get("content");
      });
    }
  }

  void updateBulletin() async {
    var firebaseUser = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance.collection('bulletin').doc(docId).update({
      "title": _textTitle.text,
      "content": _textContent.text,
      "writer": firebaseUser!.displayName,
      "date": _format(DateTime.now())
    });
    _showDialogOfCheck(context, "公告更改完成！", "上傳成功");
  }

  void releaseBulletin() async {
    var firebaseUser = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance.collection('bulletin').doc().set({
      "title": _textTitle.text,
      "content": _textContent.text,
      "writer": firebaseUser!.displayName,
      "date": _format(DateTime.now())
    });
    _showDialogOfCheck(context, "公告發布完成！", "上傳成功");
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
                    Navigator.of(context).pop();
                    if (isUpdate) {
                      Navigator.of(context).pop();
                    }
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
        middle: isUpdate ? Text("編輯公告") : Text("新增公告"),
        trailing: GestureDetector(
          child: TextButton(
            child: Text(
              "發布",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              isUpdate ? updateBulletin() : releaseBulletin();
              setState(() {
                _textTitle = TextEditingController(text: "");
                _textContent = TextEditingController(text: "");
              });
            },
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 80, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Text(
                  "標題:",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: 250,
                  child: CupertinoTextField(
                    decoration: BoxDecoration(
                        color: Colors.white24,
                        border: Border.all(
                            color: CupertinoColors.lightBackgroundGray),
                        borderRadius: BorderRadius.circular(5)),
                    maxLines: 1,
                    placeholder: "請輸入標題",
                    controller: _textTitle,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "內容:",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            CupertinoTextField(
              decoration: BoxDecoration(
                  color: Colors.white24,
                  border:
                      Border.all(color: CupertinoColors.lightBackgroundGray),
                  borderRadius: BorderRadius.circular(5)),
              maxLines: 10,
              placeholder: "請輸入內容",
              controller: _textContent,
              onChanged: (value) {
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
