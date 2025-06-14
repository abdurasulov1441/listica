// import 'package:audioplayers/audioplayers.dart';
// import 'package:listica/services/request_helper.dart';

// AudioPlayer player = AudioPlayer();
// DateTime? _lastStopAttempt;

// void playAlertSoundOperator() async {
//   try {
//     await player.setReleaseMode(ReleaseMode.loop);
//     await player.play(AssetSource('sounds/new_order.mp3'));
//     print('Playing operator alert sound (looping)');
//   } catch (e) {
//     print('Error playing operator sound: $e');
//   }
// }

// void playAlertSoundCourier() async {
//   try {
//     await player.setReleaseMode(ReleaseMode.loop);
//     await player.play(AssetSource('sounds/ready_to_delivery.mp3'));
//     print('Playing courier alert sound (looping)');
//   } catch (e) {
//     print('Error playing courier sound: $e');
//   }
// }

// Future<void> stopAlertSoundOperator({bool immediate = false}) async {
//   if (immediate) {
//     await player.stop();
//     print('Immediately stopped operator alert sound');
//     return;
//   }

//   try {
//     final response = await requestHelper.getWithAuth(
//       '/zyber/listica/api/orders/get-all-orders?status=1',
//     );

//     final orders = response['data'] as List;
//     if (orders.isEmpty) {
//       await player.stop();
//       print('No orders with status 1, stopping operator alert sound');
//     } else {
//       print('Orders with status 1 exist (${orders.length}), not stopping sound');
//     }
//   } catch (e) {
//     print('Error checking operator orders: $e');
//     await player.stop();
//     print('Stopped operator sound due to error');
//   }
// }

// Future<void> stopAlertSoundCourier({bool immediate = false}) async {
//   if (immediate) {
//     await player.stop();
//     print('Immediately stopped courier alert sound');
//     return;
//   }

//   // Debounce: Only allow stopping if at least 10 seconds have passed since last attempt
//   final now = DateTime.now();
//   if (_lastStopAttempt != null &&
//       now.difference(_lastStopAttempt!).inSeconds < 10) {
//     print('Stop attempt ignored (within 10s debounce period)');
//     return;
//   }

//   try {
//     print('Checking orders with status=4');
//     final response = await requestHelper.getWithAuth(
//       '/zyber/listica/api/orders/get-all-orders?status=4',
//     );

//     final orders = response['data'] as List;
//     if (orders.isEmpty) {
//       await player.stop();
//       print('No orders with status 4, stopping courier alert sound');
//     } else {
//       print('Orders with status 4 exist (${orders.length}), not stopping sound');
//     }
//     _lastStopAttempt = now;
//   } catch (e) {
//     print('Error checking courier orders: $e');
//     await player.stop();
//     print('Stopped courier sound due to error');
//     _lastStopAttempt = now;
//   }
// }
