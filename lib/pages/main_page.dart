import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:listica/pages/home/home.dart';
import 'package:listica/pages/lists/lists.dart';
import 'package:listica/pages/settings/settings.dart';
import 'package:listica/services/style/app_colors.dart';
import 'package:listica/services/style/app_style.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [HomePage(), GroupPage(), SettingsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        backgroundColor: AppColors.backgroundColor,
        selectedLabelStyle: AppStyle.fontStyle,
        selectedItemColor: AppColors.logoColor1,
        unselectedItemColor: AppColors.logoColor2,
        unselectedLabelStyle: AppStyle.fontStyle,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/home.png',
              color: AppColors.logoColor1,
            ),
            label: 'home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/order.png',
              color: AppColors.logoColor1,
            ),
            label: 'group'.tr(),
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/account.png',
              color: AppColors.logoColor1,
            ),
            label: 'settings'.tr(),
          ),
        ],
      ),
    );
  }
}
