// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class FlowMeter {
  String numberOfFlowMeter;
  String owner;
  String date;
  FlowMeter(this.numberOfFlowMeter, this.owner, this.date);
}

class _SearchPageState extends State<SearchPage> {
  static var firebaseUser = FirebaseAuth.instance.currentUser;
  late TextEditingController _textController;
  final Stream<QuerySnapshot> _userStream = FirebaseFirestore.instance
      .collection("waterMeter")
      .orderBy("date", descending: true)
      .snapshots();

  List<FlowMeter> flowMeterList = [];
  bool isFetch = false;

  @override
  void initState() {
    super.initState();
    updateInfo();
    _textController = TextEditingController();
  }

  void updateInfo() async {
    final snapShot = await FirebaseFirestore.instance
        .collection('waterMeter')
        .orderBy("date", descending: true)
        .get();

    if (snapShot.docs.isNotEmpty) {
      for (var doc in snapShot.docs) {
        flowMeterList.add(FlowMeter(doc.id, doc["owner"], doc["date"]));
      }
    }
    setState(() => isFetch = true);
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      List<FlowMeter> listAfterSearching = [];
      flowMeterList.forEach((item) {
        if (item.numberOfFlowMeter.contains(query) ||
            item.owner.contains(query)) {
          listAfterSearching.add(item);
        }
      });
      setState(() {
        flowMeterList.clear();
        flowMeterList.addAll(listAfterSearching);
      });
      return;
    } else {
      setState(() {
        flowMeterList.clear();
        updateInfo();
      });
    }
    setState(() => isFetch = true);
  }

  Widget searchField() {
    return CupertinoSearchTextField(
      controller: _textController,
      onChanged: (value) => filterSearchResults(value),
    );
  }

  // OLD
  // Widget buildListView() {
  //   return StreamBuilder<QuerySnapshot>(
  //     stream: _userStream,
  //     builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
  //       if (snapshot.hasError) {
  //         return Text('Something went wrong');
  //       }

  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return Center(
  //           child: CupertinoActivityIndicator(),
  //         );
  //       }

  //       return ListView(
  //         children: snapshot.data!.docs.map((DocumentSnapshot document) {
  //           Map<String, dynamic> data =
  //               document.data()! as Map<String, dynamic>;
  //           return Card(
  //             child: ListTile(
  //               title: Row(
  //                 children: <Widget>[
  //                   Align(
  //                     alignment: Alignment.centerLeft,
  //                     child: Text(
  //                       document.id,
  //                       style: TextStyle(
  //                           fontSize: 20, fontWeight: FontWeight.bold),
  //                     ),
  //                   ),
  //                   Align(
  //                     alignment: Alignment.centerRight,
  //                     child: Text(
  //                       data["owner"],
  //                       style: TextStyle(fontSize: 15),
  //                     ),
  //                   )
  //                 ],
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               ),
  //               subtitle: Text(
  //                 data["date"],
  //                 style: TextStyle(fontSize: 12),
  //               ),
  //             ),
  //           );
  //         }).toList(),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("表冊"),
        ),
        child: isFetch
            ? Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 80, 10, 0),
                    child: searchField(),
                  ),
                  Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: flowMeterList.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                title: Row(
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        flowMeterList[index].numberOfFlowMeter,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        flowMeterList[index].owner,
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    )
                                  ],
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                ),
                                subtitle: Text(
                                  flowMeterList[index].date,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            );
                          }))
                ],
              )
            : Center(child: CupertinoActivityIndicator()));
  }
}
