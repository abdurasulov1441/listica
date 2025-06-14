import 'package:go_router/go_router.dart';
import 'package:listica/pages/auth/login_screen.dart';
import 'package:listica/pages/auth/reset_password_screen.dart';
import 'package:listica/pages/auth/signup_screen.dart';
import 'package:listica/pages/auth/verify_email_screen.dart';
import 'package:listica/pages/main_page.dart';
import 'package:listica/services/firebase_streem.dart';

abstract class Routes {
  static const stream = '/stream';
  static const homeScreen = '/homeScreen';
  static const loginScreen = '/loginScreen';
  static const passwordRecoveryPage = '/passwordRecoveryPage';
  static const register = '/register';
  static const verifyEmailScreen = '/verifyEmailScreen';
  static const String listDetails = '/list-details';
  static const pairingScreen = '/pairing';

}

String _initialLocation() {
  return Routes.stream;
}

Object? _initialExtra() {
  return {};
}

final router = GoRouter(
  initialLocation: _initialLocation(),
  initialExtra: _initialExtra(),
  routes: [
    GoRoute(
      path: Routes.stream,
      builder: (context, state) => const FirebaseStream(),
    ),
    GoRoute(
      path: Routes.homeScreen,
      builder: (context, state) => const MainPage(),
    ),
    GoRoute(
      path: Routes.loginScreen,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: Routes.passwordRecoveryPage,
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: Routes.register,
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: Routes.verifyEmailScreen,
      builder: (context, state) => const VerifyEmailScreen(),
    ),
    
    
  ],
);
