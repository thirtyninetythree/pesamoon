import 'dart:io';

import 'package:flutter/material.dart';

import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScan extends StatefulWidget {
  static const routeName = "/qr-scan";
  const QRScan({Key? key}) : super(key: key);

  @override
  _QRScanState createState() => _QRScanState();
}

class _QRScanState extends State<QRScan> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  void pauseCamera() async {
    await controller?.pauseCamera();
  }

  void resumeCamera() async {
    await controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("QRScan"),
        ),
        body: Column(children: [
          Expanded(flex: 3, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: result != null
                ? Text(
                    'Barcode Type:(result!.format)}   Data: ${result?.code!.substring(9)}')
                : const Text('Scan a barcode'),
          ),
          Expanded(
              flex: 1,
              child: Row(
                children: [
                  OutlinedButton(
                      onPressed: pauseCamera, child: const Text("Pause")),
                  OutlinedButton(
                      onPressed: resumeCamera, child: const Text("Resume")),
                  OutlinedButton(
                      onPressed: _onQRScanCreated, child: const Text("DONE")),
                ],
              )),
        ]));
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  void _onQRScanCreated() {
    Navigator.pop(context, result?.code!.substring(9));
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    // print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
