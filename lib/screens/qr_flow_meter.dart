// ignore_for_file: prefer_const_constructors, prefer_if_null_operators

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:practice/screens/take_meter_new.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanPageForMeter extends StatefulWidget {
  const QRScanPageForMeter({Key? key}) : super(key: key);

  @override
  _QRScanPageForMeterState createState() => _QRScanPageForMeterState();
}

class _QRScanPageForMeterState extends State<QRScanPageForMeter> {
  final qrkey = GlobalKey(debugLabel: "QR");

  Barcode? barcode;
  QRViewController? controller;
  bool isBarcodeCreated = false;

  @override
  void initState() {
    isBarcodeCreated = false;
    controller?.resumeCamera();
    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();

    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
          child: CupertinoPageScaffold(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            buildQrView(context),
            Positioned(bottom: 10, child: buildResult()),
            isBarcodeCreated
                ? TakeMeterNew(number: barcode!.code)
                : Container(),
          ],
        ),
      ));

  Widget buildResult() => Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), color: Colors.white24),
      child: CupertinoButton(
          child: Row(
            children: [
              Icon(
                CupertinoIcons.plus_circle_fill,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              SizedBox(
                width: 250,
                child: Center(
                  child: Text(
                    barcode != null ? barcode!.code.toString() : "請掃描水表QRcode",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    maxLines: 3,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            if (barcode != null) {
              setState(() {
                isBarcodeCreated = true;
                controller!.pauseCamera();
              });
            } else {
              _showDialog(context);
            }
          }));

  Widget buildQrView(BuildContext context) => QRView(
        key: qrkey,
        onQRViewCreated: onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderWidth: 5,
          borderLength: 20,
          borderRadius: 10,
          borderColor: Colors.blue,
          cutOutSize: MediaQuery.of(context).size.width * 0.8,
        ),
      );

  void onQRViewCreated(QRViewController controller) {
    setState(() => this.controller = controller);

    controller.scannedDataStream.listen((barcode) {
      // setState
      setState(() => this.barcode = barcode);
    });
  }

  _showDialog(BuildContext context) {
    showCupertinoDialog<void>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text("錯誤"),
              content: Text("請掃描水表QRcode"),
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
}
