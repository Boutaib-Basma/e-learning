import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveBackgroundNotification(
    NotificationResponse notificationResponse,
  ) async {}
  static Future<void> initNotification() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("@mipmap/ic_notification");
    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotification,
      onDidReceiveNotificationResponse: onDidReceiveBackgroundNotification,
    );

    // Create the notification channel for Android 8.0 and above
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'app_notification', // id
      'channel_name', // name
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // await flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //         AndroidFlutterLocalNotificationsPlugin>()
    //     ?.requestNotificationsPermission();
  }

  static Future<void> showInstantNotification(String title, String body) async {
    try {

      // Then show notification
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'app_notification',
        'High Priority Channel',
        channelDescription: 'Important notifications',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_notification',
        playSound: false, // We're handling sound manually
        // sound: RawResourceAndroidNotificationSound('rington'),
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentSound: false, // Disable system sound
      );

      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        const NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
      );
    } catch (e) {
      debugPrint('Notification Error: $e');
    }
  }

  static Future<void> scheduleNotification(
    String title,
    String body,
    DateTime scheduledDate,
  ) async {
    const NotificationDetails platfomChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        "app_notification",
        "channel_name",
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await flutterLocalNotificationsPlugin.zonedSchedule(
      androidScheduleMode: AndroidScheduleMode.exact,
      0,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platfomChannelSpecifics,

    );
  }
}