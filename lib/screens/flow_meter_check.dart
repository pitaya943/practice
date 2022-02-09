// ignore_for_file: prefer_const_constructors, no_logic_in_create_state, unrelated_type_equality_checks

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FlowMeterCheck extends StatefulWidget {
  const FlowMeterCheck({Key? key}) : super(key: key);

  @override
  _FlowMeterCheckState createState() => _FlowMeterCheckState();
}

class _FlowMeterCheckState extends State<FlowMeterCheck> {
  static var firebaseUser = FirebaseAuth.instance.currentUser;
  var flowMeterCount = 0;

  String _format(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime).toString();
  }

  final DateTime now = DateTime.now();

  @override
  void initState() {
    countNumber();
    super.initState();
  }

  final Stream<QuerySnapshot> _userStream = FirebaseFirestore.instance
      .collection('users')
      .doc(firebaseUser!.uid)
      .collection("waterMeter")
      .orderBy("date", descending: true)
      .snapshots();

  void countNumber() async {
    final snapShot = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser!.uid)
        .collection("waterMeter")
        .get();

    if (snapShot.docs.isNotEmpty) {
      for (var value in snapShot.docs) {
        if (value["date"].toString().substring(0, 10) == _format(now)) {
          setState(() => flowMeterCount++);
        }
      }
    }
  }

  Widget buildListView() {
    return StreamBuilder<QuerySnapshot>(
      stream: _userStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CupertinoActivityIndicator(),
          );
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            if (data["date"].toString().substring(0, 10) == _format(now)) {
              return Card(
                child: ListTile(
                  title: Text(
                    document.id,
                    style: TextStyle(fontSize: 20),
                  ),
                  subtitle: Text(
                    data["date"],
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              );
            }
            return Container();
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("查看今日領取表號"),
          trailing: Text(flowMeterCount.toString()),
        ),
        child: buildListView());
  }
}
