// ignore_for_file: prefer_const_constructors

import 'package:practice/screens/bulletin.dart';
import 'package:practice/screens/qr_flow_meter.dart';
import 'package:practice/screens/take_meter.dart';
import 'package:practice/screens/check_in.dart';
import 'package:flutter/cupertino.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  var screens = [
    CheckIn(),
    TakeMeter(),
    QRScanPageForMeter(),
    BulletinView(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CupertinoTabScaffold(
        resizeToAvoidBottomInset: false,
        tabBar: CupertinoTabBar(
          // ignore: prefer_const_literals_to_create_immutables
          items: [
            BottomNavigationBarItem(
              label: "簽到",
              icon: Icon(CupertinoIcons.pencil_circle),
            ),
            // BottomNavigationBarItem(
            //   label: "上傳",
            //   icon: Icon(CupertinoIcons.cloud_upload_fill),
            // ),
            BottomNavigationBarItem(
              label: "領表",
              icon: Icon(CupertinoIcons.wrench),
            ),
            BottomNavigationBarItem(
              label: "QRcode領表",
              icon: Icon(CupertinoIcons.wrench_fill),
            ),
            BottomNavigationBarItem(
              label: "公告",
              icon: Icon(CupertinoIcons.book_circle_fill),
            ),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return screens[index];
        },
      ),
    );
  }
}
