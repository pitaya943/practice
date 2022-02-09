// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_types_as_parameter_names, non_constant_identifier_names, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:practice/screens/new_bulletin.dart';
import 'package:practice/screens/search_flow_meter.dart';

import 'detail_bulletin.dart';

class BulletinView extends StatefulWidget {
  const BulletinView({Key? key}) : super(key: key);

  @override
  _BulletinViewState createState() => _BulletinViewState();
}

class _BulletinViewState extends State<BulletinView> {
  bool isAdmin = false;
  bool isLoading = true;

  @override
  void initState() {
    getAccess();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getAccess() async {
    var firebaseUser = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('admin')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc.id == firebaseUser!.uid) {
          setState(() => isAdmin = true);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CupertinoNavigationBar(
          middle: Text("公告"),
          leading: GestureDetector(
            child: isAdmin
                ? TextButton(
                    child: Icon(CupertinoIcons.add),
                    onPressed: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (builder) => NewBulletin()));
                    },
                  )
                : null,
          ),
          trailing: GestureDetector(
            child: isAdmin
                ? TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (builder) => SearchPage()));
                    },
                    child: Icon(CupertinoIcons.book))
                : null,
          ),
        ),
        body: buildListView());
  }

  final Stream<QuerySnapshot> _bulletinStream = FirebaseFirestore.instance
      .collection('bulletin')
      .orderBy("date", descending: true)
      .snapshots();

  Widget buildListView() {
    return StreamBuilder<QuerySnapshot>(
      stream: _bulletinStream,
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
            return Card(
              child: ListTile(
                title: Text(
                  data["title"],
                  style: TextStyle(fontSize: 20),
                ),
                subtitle: Text(
                  data["date"],
                  style: TextStyle(fontSize: 15),
                ),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) =>
                              DetailView(docId: document.id)));
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
