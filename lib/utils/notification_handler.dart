import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mon_elearning/utils/notification_services.dart';
class NotificationHandler {
  static Future<void> handleForegroundMessage(RemoteMessage message) async {
    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? 'No message';

    await NotificationService.showInstantNotification(
      title,
      body,
    );
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? 'No message';

    // Let system handle sound in background
    await NotificationService.showInstantNotification(
      title,
      body,
    );
  }
}