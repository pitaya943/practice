// ignore_for_file: prefer_const_constructors, prefer_final_fields, prefer_typing_uninitialized_variables, no_logic_in_create_state

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'dart:async';

import 'package:practice/home_page.dart';

class UploadImage extends StatefulWidget {
  const UploadImage({Key? key, this.address}) : super(key: key);
  final address;

  @override
  _UploadImageState createState() => _UploadImageState(address);
}

class _UploadImageState extends State<UploadImage> {
  var firebaseUser = FirebaseAuth.instance.currentUser;
  final address;
  bool indirectCase = false;

  bool uploading = false;
  double val = 0;
  late CollectionReference imgRef;
  late firebase_storage.Reference ref;

  List<File> _image = [];
  final picker = ImagePicker();

  _UploadImageState(this.address);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("上傳照片"),
          //backgroundColor: Colors.blue,
          trailing: GestureDetector(
            onTap: () {},
            child: TextButton(
                onPressed: () {
                  if (_image.isNotEmpty) {
                    setState(() {
                      uploading = true;
                    });
                    uploadFile().whenComplete(() {
                      setState(() {
                        // reset widget
                        _showDialog(context);
                        uploading = false;
                        _image = [];
                      });
                    });
                  } else {
                    _showWarnDialog(context);
                  }
                },
                child: Text(
                  '上傳',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(4),
              child: GridView.builder(
                  itemCount: _image.length + 1,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemBuilder: (context, index) {
                    return index == 0
                        ? Center(
                            child: Container(
                              color: Colors.grey[200],
                              child: CupertinoButton(
                                  child: Icon(Icons.add),
                                  onPressed: () =>
                                      !uploading ? chooseImage() : null),
                            ),
                          )
                        : Container(
                            margin: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: FileImage(_image[index - 1]),
                                    fit: BoxFit.cover)),
                          );
                  }),
            ),
            uploading
                ? Center(
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '傳送中...',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      CircularProgressIndicator(
                        value: val,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      )
                    ],
                  ))
                : Container(),
            Positioned(bottom: 10, child: buildResult()),
            Positioned(bottom: 70, child: toggleView()),
          ],
        ));
  }

  Widget toggleView() => Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Text("是否為間接供水？"),
            SizedBox(
              width: 150,
            ),
            CupertinoSwitch(
              value: indirectCase,
              onChanged: (_) {
                setState(() => indirectCase = !indirectCase);
                print("Case state is $indirectCase");
              },
            ),
          ],
        ),
      );

  Widget buildResult() => SizedBox(
        width: 350,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8), color: Colors.grey[200]),
          child: Text(
            address ?? "錯誤地址",
            maxLines: 3,
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      );

  @override
  void initState() {
    super.initState();
    // image ref
    imgRef = FirebaseFirestore.instance.collection("imageURLs");
  }

  // show dialog
  _showDialog(BuildContext context) {
    showCupertinoDialog<void>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              // title: Text("上傳結果"),
              content: Text("上傳成功！"),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                  child: Text("確定"),
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

  _showWarnDialog(BuildContext context) {
    showCupertinoDialog<void>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              // title: Text("上傳結果"),
              content: Text("尚未選取照片"),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                  child: Text("確定"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ));
  }

  chooseImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image.add(File(pickedFile!.path));
    });
    if (pickedFile!.path == null) retrieveLostData();
  }

  Future<void> retrieveLostData() async {
    final LostData response = await picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image.add(File(response.file!.path));
      });
    } else {
      print(response.file);
    }
  }

  Future uploadFile() async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
    int i = 1;

    var _caseState = indirectCase ? "間接照片" : "一般施工";

    for (var img in _image) {
      setState(() {
        val = i / _image.length;
      });
      // image path in local data ${path.basename(img.path)}
      ref = firebase_storage.FirebaseStorage.instance.ref().child(
          '$_caseState/${firebaseUser!.displayName}/$today/$address/${path.basename(img.path)}');
      await ref.putFile(img).whenComplete(() async {
        await ref.getDownloadURL().then((value) {
          // add image urls to cloudstore
          imgRef
              .doc(firebaseUser!.displayName)
              .collection("照片日期")
              .doc(DateTime.now().toString())
              .set({'地址': address, 'url': value});
          i++;
        });
      });
    }
  }
}
