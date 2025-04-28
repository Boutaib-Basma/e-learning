import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mon_elearning/utils/notification_handler.dart';

class FirebaseMessagingService {
  static Future<void> initialize() async {
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    // Request permissions (for iOS)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configure background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await NotificationHandler.handleBackgroundMessage(message);
  }

  static void configureForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await NotificationHandler.handleForegroundMessage(message);
    });
  }
}