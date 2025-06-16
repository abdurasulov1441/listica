import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:listica/pages/lists/detail_page.dart';
import 'package:listica/services/modal/custom_expandable_dialog.dart';
import 'package:listica/services/modal/custom_modal.dart';
import 'package:listica/services/style/app_colors.dart';
import 'package:listica/services/style/app_style.dart';
import 'package:lottie/lottie.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final TextEditingController listTitleController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;

  late CollectionReference shoppingLists;
  String? pairId;

  @override
  void initState() {
    super.initState();
    _initializePair();
  }

  Future<void> _initializePair() async {
    final pairSnapshot = await FirebaseFirestore.instance
        .collection('pairing')
        .doc(user.uid)
        .get();
    if (pairSnapshot.exists) {
      final pairedWith = pairSnapshot['pairedWith'];
      if (pairedWith != null) {
        final sorted = [user.uid, pairedWith]..sort();
        pairId = '${sorted[0]}_${sorted[1]}';
        setState(() {
          shoppingLists = FirebaseFirestore.instance
              .collection('family')
              .doc(pairId)
              .collection('lists');
        });
      } else {
        setState(() {
          pairId = null;
        });
      }
    } else {
      setState(() {
        pairId = null;
      });
    }
  }

  void _createList() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => CustomExpandableInputDialog(
        title: 'new_list'.tr(),
        hintText: 'eg_shopping_list'.tr(),
        confirmText: 'add'.tr(),
        cancelText: 'cancel'.tr(),
        onConfirm: (title) {
          final trimmedTitle = title.trim();
          if (trimmedTitle.isNotEmpty) {
            shoppingLists.add({
              'title': trimmedTitle,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
          controller.clear();
        },
      ),
    );
  }

  void _confirmDelete(DocumentSnapshot listDoc) {
    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        title: "are_you_sure".tr(),
        subtitle: "will_deleted_lists".tr(),
        cancelText: "cancel".tr(),
        confirmText: "confirm".tr(),
        confirmButtonColor: Colors.red,
        onCancel: () => Navigator.pop(context),
        onConfirm: () async {
          Navigator.pop(context);
          await listDoc.reference.delete();
        },
      ),
    );
  }

  Future<int> _getItemCount(String listId) async {
    final snapshot = await shoppingLists.doc(listId).collection('items').get();
    return snapshot.size;
  }

  @override
  Widget build(BuildContext context) {
    if (pairId == null) {
      return Scaffold(
        backgroundColor: AppColors.foregroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LottieBuilder.asset('assets/lottie/unauth.json', repeat: false),
                Text(
                  'please_first_you_need_connect'.tr(),
                  textAlign: TextAlign.center,
                  style: AppStyle.fontStyle,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.foregroundColor,
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(30),
        ),
        backgroundColor: AppColors.backgroundColor,
        onPressed: _createList,
        child: const Icon(Icons.add, color: AppColors.logoColor1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: shoppingLists
                .orderBy('createdAt', descending: true)
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

              final lists = snapshot.data!.docs;

              return ListView.builder(
                itemCount: lists.length,
                itemBuilder: (context, index) {
                  final listDoc = lists[index];
                  final title = listDoc['title'];
                  final listId = listDoc.id;

                  return FutureBuilder<int>(
                    future: _getItemCount(listId),
                    builder: (context, countSnapshot) {
                      final count = countSnapshot.data ?? 0;

                      return Card(
                        color: AppColors.backgroundColor,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(
                            title,
                            style: AppStyle.fontStyle.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${'products'.tr()}: $count',
                            style: AppStyle.fontStyle.copyWith(fontSize: 14),
                          ),
                          trailing: IconButton(
                            icon: SvgPicture.asset(
                              'assets/icons/trash.svg',
                              color: AppColors.logoColor1,
                            ),
                            onPressed: () => _confirmDelete(listDoc),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailPage(
                                listId: listId,
                                title: title,
                                shoppingLists: shoppingLists,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
