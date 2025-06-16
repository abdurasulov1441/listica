import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:listica/services/modal/custom_expandable_dialog.dart';
import 'package:listica/services/modal/custom_modal.dart';
import 'package:listica/services/style/app_colors.dart';
import 'package:listica/services/style/app_style.dart';
import 'package:uuid/uuid.dart';

class DetailPage extends StatefulWidget {
  final String listId;
  final String title;
  final CollectionReference shoppingLists;

  const DetailPage({
    super.key,
    required this.listId,
    required this.title,
    required this.shoppingLists,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<DocumentSnapshot> items = [];

  void _addItem(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => CustomExpandableInputDialog(
        title: 'new_product'.tr(),
        hintText: 'eg_milk'.tr(),
        confirmText: 'add'.tr(),
        cancelText: 'cancel'.tr(),

        onConfirm: (text) async {
          final trimmed = text.trim();
          if (trimmed.isEmpty) return;

          final newItem = {
            'id': const Uuid().v4(),
            'title': trimmed,
            'done': false,
            'color': Colors.grey.value,
            'createdAt': FieldValue.serverTimestamp(),
            'order': items.length,
          };
          await widget.shoppingLists
              .doc(widget.listId)
              .collection('items')
              .add(newItem);
          controller.clear();
        },
      ),
    );
  }

  void _changeColor(DocumentSnapshot itemDoc) {
    Color selectedColor = Color(itemDoc['color'] ?? Colors.grey.value);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          'choose_color'.tr(),
          style: AppStyle.fontStyle.copyWith(fontSize: 20),
        ),
        content: BlockPicker(
          pickerColor: selectedColor,
          onColorChanged: (color) {
            itemDoc.reference.update({'color': color.value});
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _confirmDelete(DocumentSnapshot itemDoc) {
    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        title: "are_you_sure".tr(),
        subtitle: "delete_this_element".tr(),
        cancelText: "cancel".tr(),
        confirmText: "confirm".tr(),
        confirmButtonColor: Colors.red,
        onCancel: () => Navigator.pop(context),
        onConfirm: () async {
          Navigator.pop(context);
          await itemDoc.reference.delete();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.foregroundColor,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(30),
        ),
        onPressed: () => _addItem(context),
        child: const Icon(Icons.add, color: AppColors.logoColor1),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: widget.shoppingLists
            .doc(widget.listId)
            .collection('items')
            .orderBy('order')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: AppColors.backgroundColor,
                color: AppColors.logoColor1,
              ),
            );
          }
          items = snapshot.data!.docs;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final itemDoc = items[index];
              final item = itemDoc.data() as Map<String, dynamic>;
              final title = item['title'] ?? '';
              final done = item['done'] ?? false;
              final color = Color(item['color'] ?? Colors.grey.value);

              return Container(
                margin: EdgeInsets.only(top: 10, right: 10, left: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: color.withOpacity(0.2),
                ),
                key: ValueKey(itemDoc.id),

                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          decoration: done ? TextDecoration.lineThrough : null,
                          color: done ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/palette.svg',
                        width: 20,
                        height: 20,
                      ),
                      onPressed: () => _changeColor(itemDoc),
                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/trash.svg',
                        width: 20,
                        height: 20,
                      ),
                      onPressed: () => _confirmDelete(itemDoc),
                    ),
                    Checkbox(
                      value: done,
                      onChanged: (val) {
                        itemDoc.reference.update({'done': val});
                      },
                      activeColor: Colors.green,
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
