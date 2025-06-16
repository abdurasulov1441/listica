import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listica/pages/home/qr_scanner.dart';
import 'package:listica/services/buttons/custom_icon_button.dart';
import 'package:listica/services/modal/custom_input_modal.dart';
import 'package:listica/services/modal/custom_modal.dart';
import 'package:listica/services/style/app_style.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:listica/services/style/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? qrCode;
  String? pairedUid;
  bool isLoading = true;
  bool disposed = false;

  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _initializeQR();
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }

  Future<void> _initializeQR() async {
    final docRef = FirebaseFirestore.instance
        .collection('pairing')
        .doc(user.uid);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      if (!mounted || disposed) return;
      setState(() {
        qrCode = data['code'];
        pairedUid = data['pairedWith'];
        isLoading = false;
      });
    } else {
      final code = _generateCode();
      await docRef.set({
        'code': code,
        'pairedWith': null,
        'uid': user.uid,
        'email': user.email,
        'photoUrl': user.photoURL,
        'name': user.displayName,
        'created_at': FieldValue.serverTimestamp(),
      });
      if (!mounted || disposed) return;
      setState(() {
        qrCode = code;
        isLoading = false;
      });
    }
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<Map<String, dynamic>?> _getPairedUserData(String pairedUid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(pairedUid)
        .get();
    return doc.data();
  }

  void _scanQRCode(BuildContext context) async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QRCodeScannerPage(
            onScanned: (code) async {
              await _attemptPairing(code.toUpperCase());
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamera uchun ruxsat berilmadi')),
      );
    }
  }

  Future<void> _attemptPairing(String code) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('pairing')
        .where('code', isEqualTo: code)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final target = snapshot.docs.first;
      final targetUid = target.id;

      await FirebaseFirestore.instance
          .collection('pairing')
          .doc(targetUid)
          .update({'pairedWith': user.uid});

      await FirebaseFirestore.instance
          .collection('pairing')
          .doc(user.uid)
          .update({'pairedWith': targetUid});

      if (mounted && !disposed) {
        _initializeQR();
      }
    } else {
      if (mounted && !disposed) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Kod topilmadi')));
      }
    }
  }

  void _confirmUnpairing() {
    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        title: "unpair".tr(),
        subtitle: "unpair_subtitle".tr(),
        cancelText: "cancel".tr(),
        confirmText: "confirm".tr(),
        cancelButtonColor: const Color(0xFFF5F5F5),
        onCancel: () => Navigator.pop(context),
        onConfirm: () async {
          context.pop();
          await FirebaseFirestore.instance
              .collection('pairing')
              .doc(user.uid)
              .update({'pairedWith': null});
          if (pairedUid != null) {
            await FirebaseFirestore.instance
                .collection('pairing')
                .doc(pairedUid)
                .update({'pairedWith': null});
          }
          if (mounted) {
            setState(() {
              pairedUid = null;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.foregroundColor,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pairing')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: AppColors.backgroundColor,
                color: AppColors.logoColor1,
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) {
            return const Center(child: Text("Ma'lumotlar topilmadi"));
          }

          final pairedUid = data['pairedWith'];
          final qrCode = data['code'];

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (pairedUid == null) ...[
                      QrImageView(
                        data: qrCode ?? '',
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${'connection_code'.tr()}: $qrCode',
                        style: AppStyle.fontStyle.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 30),
                      CustomIconButton(
                        icon: Icons.input,
                        label: 'connect_via_code'.tr(),
                        onPressed: () => _showScanDialog(context),
                      ),
                      const SizedBox(height: 10),
                      CustomIconButton(
                        icon: Icons.qr_code_scanner,
                        label: 'connect_via_qr_code'.tr(),
                        onPressed: () => _scanQRCode(context),
                      ),
                    ] else ...[
                      FutureBuilder<Map<String, dynamic>?>(
                        future: _getPairedUserData(pairedUid),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return const CircularProgressIndicator(
                              backgroundColor: AppColors.backgroundColor,
                              color: AppColors.logoColor1,
                            );
                          }
                          final pairedData = userSnapshot.data!;
                          return Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundColor,
                              borderRadius: BorderRadius.all(
                                Radius.circular(18),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'paired'.tr(),
                                  style: AppStyle.fontStyle.copyWith(
                                    fontSize: 24,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        pairedData['photoUrl'] ?? '',
                                      ),
                                      radius: 30,
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pairedData['name'] ?? 'Ismsiz',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        Text(
                                          pairedData['email'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                CustomIconButton(
                                  icon: Icons.link_off,
                                  label: "unpair".tr(),
                                  backgroundColor: AppColors.logoColor1,
                                  foregroundColor: Colors.white,
                                  onPressed: _confirmUnpairing,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showScanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CustomInputDialog(
        title: 'connection_code'.tr(),
        hintText: 'eg_code'.tr(),
        confirmText: 'connect'.tr(),
        cancelText: 'cancel'.tr(),
        onConfirm: (code) async {
          await _attemptPairing(code);
        },
      ),
    );
  }
}
