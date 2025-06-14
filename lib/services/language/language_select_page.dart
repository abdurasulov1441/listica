import 'package:listica/services/language/language_provider.dart';
import 'package:listica/services/style/app_colors.dart';
import 'package:listica/services/style/app_style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showLanguageBottomSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  final List<Map<String, dynamic>> languages = [
    {'locale': const Locale('uz'), 'name': 'O‘zbekcha', 'flag': '🇺🇿'},
    {'locale': const Locale('ru'), 'name': 'Русский', 'flag': '🇷🇺'},
  ];

  // Получаем текущую локаль из провайдера
  final selectedLocale = ref.watch(localeProvider);

  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'choose_language'.tr(),
              style: AppStyle.fontStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final lang = languages[index];
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(localizationControllerProvider)
                        .setLocale(context, lang['locale']);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: selectedLocale == lang['locale']
                          ? AppColors.iconColor.withOpacity(0.1)
                          : Colors.white,
                      border: Border.all(
                        color: selectedLocale == lang['locale']
                            ? AppColors.iconColor
                            : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        ClipOval(
                          child: Container(
                            color: Colors.grey.shade200,
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              lang['flag'],
                              style: AppStyle.fontStyle.copyWith(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          lang['name'],
                          style: AppStyle.fontStyle.copyWith(
                            color: selectedLocale == lang['locale']
                                ? AppColors.iconColor
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

class LanguageSelectionButton extends ConsumerWidget {
  const LanguageSelectionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    print('LanguageSelectionButton locale: $currentLocale'); // Отладка

    final String currentFlag = currentLocale == const Locale('uz')
        ? '🇺🇿'
        : currentLocale == const Locale('ru')
        ? '🇷🇺'
        : '🇺🇿';

    return GestureDetector(
      onTap: () => showLanguageBottomSheet(context, ref),
      child: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        radius: 25,
        child: Text(
          currentFlag,
          style: AppStyle.fontStyle.copyWith(fontSize: 24),
        ),
      ),
    );
  }
}
