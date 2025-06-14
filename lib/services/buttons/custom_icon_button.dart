import 'package:listica/services/style/app_colors.dart';
import 'package:listica/services/style/app_style.dart';
import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool disableButton;
  final bool inProgress;
  final Color backgroundColor;
  final Color foregroundColor;
  final double borderRadius;
  final double height;
  final double? width;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.disableButton = false,
    this.inProgress = false,
    this.backgroundColor = AppColors.iconColor,
    this.foregroundColor = Colors.white,
    this.borderRadius = 30,
    this.height = 50,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton.icon(
        onPressed: (disableButton || inProgress) ? null : onPressed,
        icon: inProgress
            ? const CircularProgressIndicator(color: AppColors.iconColor)
            : Icon(icon, color: foregroundColor),
        label: Text(
          label,
          style: AppStyle.fontStyle.copyWith(color: foregroundColor),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          disabledBackgroundColor: backgroundColor.withOpacity(0.5),
          disabledForegroundColor: foregroundColor.withOpacity(0.5),
        ),
      ),
    );
  }
}
