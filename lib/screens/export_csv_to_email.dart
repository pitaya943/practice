import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class AdminPage extends StatefulWidget {
  static final TextEditingController _emailController = TextEditingController();

  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  late String filePath;
  late String currentProcess = "";
  bool isProcessing = false;

  Future<String> get _localPath async {
    final directory = await getApplicationSupportDirectory();

    return directory.absolute.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    filePath = '$path/每月簽到彙整.csv';
    return File('$path/每月簽到彙整.csv').create();
  }

  int _format(DateTime dateTime) {
    return int.parse(DateFormat('MM').format(dateTime).toString());
  }

  String _formatTwo(DateTime dateTime) {
    return DateFormat('yyyy/MM/dd HH:mm').format(dateTime);
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

  getCsv() async {
    setState(() {
      currentProcess = "Getting data from the cloud";
      isProcessing = true;
    });
    List<List<dynamic>> rows = [];
    var cloud = await FirebaseFirestore.instance
        .collection("users")
        .get()
        .whenComplete(() {
      setState(() {
        currentProcess = "Decoding data";
      });
    });

    rows.add(["user", "userId", "phoneNumber", "date", "checkIn", "checkOut"]);
    if (cloud.docs.isNotEmpty) {
      for (var outside in cloud.docs) {
        var cloudDetail = await FirebaseFirestore.instance
            .collection("users")
            .doc(outside.id)
            .collection("checkTime")
            .get();

        if (cloudDetail.docs.isNotEmpty) {
          for (var item in cloudDetail.docs) {
            List<dynamic> row = [];
            int _dateTimeNow = int.parse(item.id.toString().substring(5, 7));

            if (_dateTimeNow == (_format(DateTime.now()) - 1)) {
              row.add(outside.data()["user"]);
              row.add(outside.data()["userId"]);
              row.add(outside.data()["phoneNumber"]);
              row.add(item.id);
              row.add(item.data()["check_in_time"]);
              row.add(item.data()["check_out_time"]);

              rows.add(row);
            }
          }
        } else {
          print("cloudDetail is empty");
        }
      }

      print(rows);

      File f = await _localFile.whenComplete(() {
        setState(() {
          currentProcess = "Writing to CSV";
        });
      });
      String csv = const ListToCsvConverter().convert(rows);
      f.writeAsString(csv);
      // filePath = f.uri.path;
    } else {
      print("Fetch failed, cloud is empty");
    }
  }

  sendMailAndAttachment() async {
    final Email email = Email(
      body:
          'Data Collected and Compiled by Kuei. <br> A CSV file is attached to this <b>mail</b> <hr><br> Compiled at ${_formatTwo(DateTime.now())}',
      subject: 'Sent in ${_formatTwo(DateTime.now())}',
      recipients: [AdminPage._emailController.text],
      isHTML: true,
      attachmentPaths: [filePath],
    );

    await FlutterEmailSender.send(email);
  }

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      navigationBar: const CupertinoNavigationBar(middle: Text("簽到彙整資料(前一個月)")),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Center(
            child: Text("Welcome to DashBoard",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500)),
          ),
          Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: CupertinoTextField(
                    controller: AdminPage._emailController,
                    textAlign: TextAlign.center,
                    placeholder: "Enter destination e-mail",
                    keyboardType: TextInputType.emailAddress,
                    // validator: (str) => str!.isEmpty
                    //     ? "請輸入目標E-mail"
                    //     : (!EmailUtils.isEmail(str))
                    //         ? "無效的E-mail帳號"
                    //         : null,
                    // decoration: const InputDecoration(
                    //     labelText: "請輸入E-mail",
                    //     border: OutlineInputBorder(),
                    //     suffixIcon: Icon(Icons.email)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextButton(
                    child: const Center(
                        child: Text(
                      "發送",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    onPressed: (isProcessing)
                        ? null
                        : () async {
                            if (_formkey.currentState!.validate()) {
                              try {
                                final result =
                                    await InternetAddress.lookup('google.com');
                                if (result.isNotEmpty &&
                                    result[0].rawAddress.isNotEmpty) {
                                  await getCsv().then((v) {
                                    setState(() {
                                      currentProcess = "正在發送中...";
                                    });
                                    sendMailAndAttachment().whenComplete(() {
                                      setState(() {
                                        isProcessing = false;
                                        _showDialogOfCheck(
                                            context, "E-mail發送成功", "成功寄出");
                                      });
                                    });
                                  });
                                }
                              } on SocketException catch (_) {
                                setState(() {
                                  currentProcess = "無網路服務，請連接網路";
                                });
                              }
                            }
                          },
                  ),
                ),
                Center(
                  child: Visibility(
                    visible: (isProcessing) ? true : false,
                    child: Center(
                      child: Row(
                        children: <Widget>[
                          const SizedBox(
                              child: CircularProgressIndicator(),
                              height: 25,
                              width: 25),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(currentProcess),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
