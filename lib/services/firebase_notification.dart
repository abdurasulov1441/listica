// import 'package:listica/services/db/cache.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';

// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   debugPrint("Фоновое сообщение: ${message.notification?.title}");
// }

// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   bool _isNotificationEnabled = true;

//   Future<void> initNotifications() async {
//     await _loadNotificationPreference();
//     if (_isNotificationEnabled) {
//       await _setupFirebaseMessaging();
//       await _setupLocalNotifications();
//     } else {
//       debugPrint("Bildirishnomalar o‘chirilgan, FCM ishlamaydi.");
//     }
//   }

//   Future<void> _loadNotificationPreference() async {
//     _isNotificationEnabled = cache.getBool('isNotification') ?? true;
//   }

//   Future<void> _setupFirebaseMessaging() async {
//     final FirebaseMessaging messaging = FirebaseMessaging.instance;
//     final status = await Permission.notification.status;

//     if (!status.isGranted) {
//       final result = await Permission.notification.request();

//       if (result.isPermanentlyDenied) {
//         debugPrint('⚠️ Разрешение навсегда отклонено. Открываем настройки...');

//         return;
//       }

//       if (!result.isGranted) {
//         debugPrint('❌ Пользователь всё ещё не дал разрешение.');
//         return;
//       }
//     }

//     debugPrint('✅ Уведомления разрешены.');

//     String? token = await messaging.getToken();
//     debugPrint("📲 FCM Token: $token");

//     await cache.setString('fcm_token', token!);

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       debugPrint(
//         '📨 Получено сообщение в активном состоянии: ${message.notification?.title}',
//       );

//       if (_isNotificationEnabled) {
//         _showLocalNotification(
//           title: message.notification?.title ?? 'Yangi xabar',
//           body: message.notification?.body ?? 'Нет описания',
//         );
//       }
//     });

//     FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
//   }

//   Future<void> _setupLocalNotifications() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);

//     await _localNotificationsPlugin.initialize(initializationSettings);
//   }

//   Future<void> _showLocalNotification({
//     required String title,
//     required String body,
//   }) async {
//     if (!_isNotificationEnabled) return;

//     const AndroidNotificationDetails androidNotificationDetails =
//         AndroidNotificationDetails(
//           'default_channel_id',
//           'Основной канал',
//           channelDescription:
//               'Этот канал используется для основных уведомлений',
//           importance: Importance.high,
//           priority: Priority.high,
//         );

//     const NotificationDetails notificationDetails = NotificationDetails(
//       android: androidNotificationDetails,
//     );

//     await _localNotificationsPlugin.show(0, title, body, notificationDetails);
//   }
// }
