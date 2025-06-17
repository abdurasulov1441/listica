import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:listica/app/router.dart';
import 'package:listica/pages/auth/auth_provider.dart';
import 'package:listica/services/language/language_select_page.dart';
import 'package:listica/services/style/app_colors.dart';
import 'package:listica/services/style/app_style.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  Future<void> _signOut() async {
    await ref.read(authNotifierProvider).signOut();
    if (!mounted) return;
    context.go(Routes.loginScreen);
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'account'.tr(),
          style: AppStyle.fontStyle.copyWith(color: Colors.black),
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: userAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            backgroundColor: AppColors.backgroundColor,
            color: AppColors.logoColor1,
          ),
        ),
        error: (e, _) => Center(child: Text('Xatolik: $e')),
        data: (user) {
          return Column(
            children: [
              const SizedBox(height: 20),

           
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.iconColor.withOpacity(0.2),
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                user?.email ?? 'email mavjud emas',
                style: AppStyle.fontStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      leading: const Icon(
                        Icons.lock_outline,
                        color: Colors.black54,
                      ),
                      title: Text('restore_password'.tr()),
                      onTap: () {
                        //  router.push(Routes.passwordRecoveryPage);
                      },
                    ),
                    const Divider(height: 0),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      leading: const Icon(
                        Icons.language,
                        color: Colors.black54,
                      ),
                      title: Text('change_language'.tr()),
                      onTap: () {
                        showLanguageBottomSheet(context, ref);
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(),
              Text(
                'Powered by Zyber Group',
                style: AppStyle.fontStyle.copyWith(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              Text(
                'Created by Abdurasulov Abdulaziz',
                style: AppStyle.fontStyle.copyWith(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: Text(
                      'logout'.tr(),
                      style: AppStyle.fontStyle.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
