import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

// Провайдер для текущей локали
final localeProvider = StateProvider<Locale>((ref) {
  // Инициализация локали по умолчанию (будет переопределена при запуске)
  return const Locale('uz');
});

// Провайдер для управления локализацией
final localizationControllerProvider = Provider<LocalizationController>((ref) {
  return LocalizationController(ref);
});

class LocalizationController {
  final Ref _ref;

  LocalizationController(this._ref);

  Future<void> setLocale(BuildContext context, Locale locale) async {
    // Устанавливаем локаль в EasyLocalization
    await context.setLocale(locale);
    // Обновляем провайдер
    _ref.read(localeProvider.notifier).state = locale;
    // Сохраняем локаль в SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
  }

  Future<void> initLocale(BuildContext context) async {
    // Получаем сохраненную локаль
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('locale') ?? 'uz'; // По умолчанию узбекский
    final savedLocale = Locale(languageCode);
    // Устанавливаем локаль
    await context.setLocale(savedLocale);
    _ref.read(localeProvider.notifier).state = savedLocale;
  }
}