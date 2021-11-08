// ignore_for_file: prefer_final_fields, prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:practice/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserName extends StatelessWidget {
  UserName({Key? key}) : super(key: key);

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  var firebaseUser = FirebaseAuth.instance.currentUser;
  var _text = TextEditingController();

// User information upload to firebase
  Future<void> _setUserInfo(String user) async {
    final SharedPreferences prefs = await _prefs;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser!.uid)
        .set({
      "user": user,
      "userId": firebaseUser!.uid,
      "phoneNumber": firebaseUser!.phoneNumber
    }).then((_) {
      // set sharedpreference
      prefs.setString("user", user);
      prefs.setString("user_uid", firebaseUser!.uid);
      prefs.setBool("login_state", true);
      prefs.setString(
          "user_number", firebaseUser!.phoneNumber ?? "did't get phone number");

      print("User info set successful");
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("請輸入您的全名！"),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 55),
            child: CupertinoTextField(
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
              maxLength: 15,
              controller: _text,
              keyboardType: TextInputType.name,
              autofillHints: <String>[AutofillHints.name],
            ),
          ),
          CupertinoButton.filled(
              child: Text("確定"),
              onPressed: () async {
                await FirebaseAuth.instance.currentUser!
                    .updateDisplayName(_text.text);
                _setUserInfo(_text.text);

                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                    (route) => false);
              })
        ],
      ),
    );
  }
}
