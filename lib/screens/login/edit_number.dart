// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:practice/screens/login/verify_number.dart';

class EditNumber extends StatefulWidget {
  const EditNumber({Key? key}) : super(key: key);

  @override
  _EditNumberState createState() => _EditNumberState();
}

class _EditNumberState extends State<EditNumber> {
  var _enterPhoneNumber = TextEditingController();
  Map<String, dynamic> data = {"code": "+886"};
  Map<String, dynamic>? dataResult;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("員工登錄"),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/YuCheng.png', width: 200.0, height: 200.0),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: CupertinoTextField(
              maxLength: 10,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              placeholder: "請輸入您的手機號碼",
              controller: _enterPhoneNumber,
              keyboardType: TextInputType.number,
              style: TextStyle(
                  fontSize: 20, color: CupertinoColors.secondaryLabel),
            ),
          ),
          CupertinoButton.filled(
              child: Text("取得驗證碼"),
              onPressed: () async {
                await Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => VerifyNumber(
                              number: data["code"]! +
                                  _enterPhoneNumber.text.substring(1).trim(),
                            )));

                _enterPhoneNumber.clear();
              }),
        ],
      ),
    );
  }
}
