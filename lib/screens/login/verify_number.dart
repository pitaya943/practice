// ignore_for_file: prefer_const_constructors, prefer_typing_uninitialized_variables, prefer_final_fields, prefer_const_literals_to_create_immutables, no_logic_in_create_state

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:practice/screens/login/edit_number.dart';
import 'package:practice/screens/login/user_name.dart';

enum Status { Wating, Error }

class VerifyNumber extends StatefulWidget {
  const VerifyNumber({Key? key, this.number}) : super(key: key);
  final number;

  @override
  _VerifyNumberState createState() => _VerifyNumberState(number);
}

class _VerifyNumberState extends State<VerifyNumber> {
  final phoneNumber;
  var _status = Status.Wating;
  var _verificationId;
  var _textEditingController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;

  _VerifyNumberState(this.phoneNumber);

  @override
  void initState() {
    super.initState();
    _verifyPhoneNumber();
  }

  Future _verifyPhoneNumber() async {
    _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.toString(),
        //timeout: const Duration(seconds: 60),
        verificationCompleted: (phonesAuthCredentials) async {
          print(phonesAuthCredentials);
          print("Verification completed");
        },
        verificationFailed: (verificationFailed) async {
          _showDialogOfWrongNumber(context, "手機號碼輸入錯誤", "驗證失敗");
          print("Verification failed\n$verificationFailed");
        },
        codeSent: (verificationId, resendingToken) async {
          print("Code sented");
          setState(() {
            _verificationId = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (verificationId) async {});
  }

  Future _sendCodeToFirebase({String? code}) async {
    if (_verificationId != null) {
      var credential = PhoneAuthProvider.credential(
          verificationId: _verificationId, smsCode: code!);

      await _auth
          .signInWithCredential(credential)
          .then((value) {
            Navigator.push(
                context, CupertinoPageRoute(builder: (context) => UserName()));
          })
          .whenComplete(() {})
          .onError((error, stackTrace) {
            setState(() {
              print("Sending Code wrong");
              _textEditingController.text = "";
              _status = Status.Error;
            });
          });
    }
  }

  // show dialog
  _showDialogOfWrongNumber(BuildContext context, String content, String title) {
    showCupertinoDialog<void>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                  child: Text("確定"),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => EditNumber()),
                        (route) => false);
                  },
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("進行手機驗證"),
          previousPageTitle: "上一頁",
        ),
        child: _status != Status.Error
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text("OTP 驗證",
                        style: TextStyle(
                            color: Colors.blue.withOpacity(0.7),
                            fontSize: 30,
                            fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text("傳送驗證碼至",
                      style: TextStyle(
                          color: CupertinoColors.secondaryLabel, fontSize: 20)),
                  SizedBox(
                    height: 10,
                  ),
                  Text("+${int.parse(phoneNumber).toString()}"),
                  SizedBox(
                    height: 15,
                  ),
                  CupertinoTextField(
                    onChanged: (value) async {
                      if (value.length == 6) {
                        //perform the auth verification
                        _sendCodeToFirebase(code: value);
                      }
                    },
                    textAlign: TextAlign.center,
                    style: TextStyle(letterSpacing: 25, fontSize: 30),
                    maxLength: 6,
                    controller: _textEditingController,
                    keyboardType: TextInputType.number,
                    autofillHints: <String>[AutofillHints.telephoneNumber],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("沒有收到驗證碼？"),
                      CupertinoButton(
                          child: Text("重新傳送驗證碼"),
                          onPressed: () async {
                            setState(() {
                              _status = Status.Wating;
                            });
                            _verifyPhoneNumber();
                            print("Resend code");
                          })
                    ],
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text("OTP 驗證",
                        style: TextStyle(
                            color: Colors.blue.withOpacity(0.7), fontSize: 30)),
                  ),
                  Text("驗證碼錯誤!"),
                  CupertinoButton(
                      child: Text("重新輸入手機號碼"),
                      onPressed: () => Navigator.pop(context)),
                  CupertinoButton(
                      child: Text("重新重送驗證碼"),
                      onPressed: () async {
                        setState(() {
                          _status = Status.Wating;
                        });
                        _verifyPhoneNumber();
                        print("Resend code");
                      }),
                ],
              ));
  }
}
