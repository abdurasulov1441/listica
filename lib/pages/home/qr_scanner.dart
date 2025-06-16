import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listica/services/style/app_colors.dart';
import 'package:listica/services/style/app_style.dart';
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
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          'scan_qr_code'.tr(),
          style: AppStyle.fontStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
