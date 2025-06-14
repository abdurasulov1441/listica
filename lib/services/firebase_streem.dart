import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:listica/pages/auth/verify_email_screen.dart';
import 'package:listica/pages/auth/login_screen.dart'; // <--- добавь этот импорт
import 'package:listica/pages/main_page.dart';

class FirebaseStream extends StatelessWidget {
  const FirebaseStream({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Something went wrong!')),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const LoginScreen(); // ⬅️ если не авторизован
        }

        if (!user.emailVerified) {
          return const VerifyEmailScreen();
        }

        return const MainPage(); // ⬅️ если всё ок
      },
    );
  }
}
