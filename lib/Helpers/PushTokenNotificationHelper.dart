import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'PushTokenAPIHelper.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class PushTokenNotificationHelper {
  static Future<void> initialize() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await PushTokenAPIHelper.registerPushToken(
        token,
        platform: defaultTargetPlatform.name,
      );
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      await PushTokenAPIHelper.registerPushToken(
        token,
        platform: defaultTargetPlatform.name,
      );
    });

    FirebaseMessaging.onMessage.listen((message) async {
      final notification = message.notification;
      if (notification == null) return;

      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'fall_alerts',
            'Fall Alerts',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    });
  }
}
