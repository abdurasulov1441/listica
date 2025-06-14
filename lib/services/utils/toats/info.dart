import 'package:listica/services/style/app_colors.dart';
import 'package:listica/services/style/app_style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showInfoToast(BuildContext context, String title, String message) {
  toastification.show(
    context: context,
    animationBuilder: (context, animation, alignment, child) => FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    ),
    type: ToastificationType.info,
    style: ToastificationStyle.flat,
    title: Text(
      title.tr(),
      style: AppStyle.fontStyle.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.backgroundColor,
      ),
    ),
    description: Text(
      message.tr(),
      style: AppStyle.fontStyle.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.backgroundColor,
      ),
    ),
    alignment: Alignment.topRight,
    backgroundColor: Colors.blue.shade700,
    foregroundColor: Colors.white,
    icon: const Icon(Icons.info, color: Colors.white),
    autoCloseDuration: const Duration(seconds: 3),
  );
}
