// ignore_for_file: no_logic_in_create_state, prefer_typing_uninitialized_variables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:practice/screens/new_bulletin.dart';

class DetailView extends StatefulWidget {
  const DetailView({Key? key, required this.docId}) : super(key: key);
  final docId;

  @override
  _DetailViewState createState() => _DetailViewState(docId);
}

class _DetailViewState extends State<DetailView> {
  bool isLoading = true;
  bool isAdmin = false;

  final docId;
  late String title;
  late String content;
  late String date;
  late String writer;

  _DetailViewState(this.docId);

  @override
  void initState() {
    getDocData();
    super.initState();
  }

  void getDocData() async {
    var firebaseUser = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('admin')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc.id == firebaseUser!.uid) {
          isAdmin = true;
        }
      }
    });
    await FirebaseFirestore.instance
        .collection('bulletin')
        .doc(docId)
        .get()
        .then((data) {
      title = data.get("title");
      content = data.get("content");
      date = data.get("date");
      writer = data.get("writer");
    });

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CupertinoPageScaffold(
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          )
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text(title),
              trailing: GestureDetector(
                child: isAdmin
                    ? TextButton(
                        child: Text(
                          "編輯",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (builder) => NewBulletin(
                                        docId: docId,
                                      )));
                        },
                      )
                    : null,
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(content),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("$date\t\t"),
                      Text(writer),
                    ],
                  ),
                ],
              ),
            ));
  }
}
