import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:listica/pages/home/qr_scanner.dart';
import 'package:listica/services/utils/utils.dart';
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
      builder: (_) => AlertDialog(
        title: const Text("Diqqat"),
        content: const Text(
          "Siz haqiqatdan ham juftlikni bekor qilmoqchimisiz?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Yo'q"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
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
            child: const Text("Ha, bekor qilish"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pairing')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) {
            return const Center(child: Text("Ma'lumotlar topilmadi"));
          }

          final pairedUid = data['pairedWith'];
          final qrCode = data['code'];

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
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
                    'Sizning kod: $qrCode',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => _showScanDialog(context),
                    child: const Text('Kod bilan bog‘lash'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _scanQRCode(context),
                    child: const Text('QR kodni skanerlash'),
                  ),
                ] else ...[
                  FutureBuilder<Map<String, dynamic>?>(
                    future: _getPairedUserData(pairedUid),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      final pairedData = userSnapshot.data!;
                      return Column(
                        children: [
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                          ElevatedButton(
                            onPressed: _confirmUnpairing,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text("Juftlikni bekor qilish"),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showScanDialog(BuildContext context) {
    final codeController = TextEditingController();
    codeController.text.trim().toUpperCase();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ulashish kodi'),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(hintText: 'Masalan: GS7X5E'),
          inputFormatters: [UpperCaseTextFormatter()],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = codeController.text.trim().toUpperCase();
              Navigator.pop(context);
              await _attemptPairing(code);
            },
            child: const Text('Ulash'),
          ),
        ],
      ),
    );
  }
}
