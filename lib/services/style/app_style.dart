import 'package:listica/services/style/app_colors.dart';
import 'package:flutter/material.dart';

abstract class AppStyle {
  static const fontStyle = TextStyle(
    fontSize: 15,
    color: AppColors.textColor,
    fontFamily: 'Poppins',
  );
}
