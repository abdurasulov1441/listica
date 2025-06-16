import 'package:flutter/material.dart';
import 'package:listica/services/style/app_style.dart';
import 'package:listica/services/style/app_colors.dart';

class CustomExpandableInputDialog extends StatelessWidget {
  final String title;
  final String hintText;
  final String confirmText;
  final String cancelText;
  final void Function(String) onConfirm;

  const CustomExpandableInputDialog({
    super.key,
    required this.title,
    required this.hintText,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Dialog(
      backgroundColor: AppColors.foregroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppStyle.fontStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            /// ✅ Встроенный многострочный TextField
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 3,
                textCapitalization: TextCapitalization.sentences,
                style: AppStyle.fontStyle,
                decoration: InputDecoration(
                  hintText: hintText,
                  filled: true,
                  fillColor: AppColors.backgroundColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      cancelText,
                      style: AppStyle.fontStyle.copyWith(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.logoColor1,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm(controller.text.trim());
                    },
                    child: Text(
                      confirmText,
                      style: AppStyle.fontStyle.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
