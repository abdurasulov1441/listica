import 'package:flutter/material.dart';
import 'package:listica/services/style/app_style.dart';
import 'package:listica/services/style/app_colors.dart';
import 'package:listica/services/textfields/custom_text_filed.dart';

class CustomInputDialog extends StatelessWidget {
  final String title;
  final String hintText;
  final String confirmText;
  final String cancelText;
  final void Function(String) onConfirm;

  const CustomInputDialog({
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

            CustomTextField(
              controller: controller,
              hintText: hintText,
              keyboardType: TextInputType.text,
              
              onChanged: (value) =>
                  controller.value = controller.value.copyWith(
                    text: value.toUpperCase(),
                    selection: TextSelection.collapsed(offset: value.length),
                  ),
                  customDecoration: null,
              
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
                      onConfirm(controller.text.trim().toUpperCase());
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
