import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRCodeScannerPage extends StatefulWidget {
  final Function(String code) onScanned;

  const QRCodeScannerPage({super.key, required this.onScanned});

  @override
  State<QRCodeScannerPage> createState() => _QRCodeScannerPageState();
}

class _QRCodeScannerPageState extends State<QRCodeScannerPage> {
  bool isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Kodni skanerlash')),
      body: MobileScanner(
        onDetect: (capture) {
          if (isScanned) return;
          final barcode = capture.barcodes.first;
          final code = barcode.rawValue;
          if (code != null) {
            isScanned = true;
            widget.onScanned(code);
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}
