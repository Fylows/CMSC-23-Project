import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService instance = NotificationService.internal();

  factory NotificationService() {
    return instance;
  }

  NotificationService.internal();

  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // request user for permission 
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (kDebugMode) {
      print('Permission status: ${settings.authorizationStatus}');
    }

    // handle the foreground messages
    FirebaseMessaging.onMessage.listen(handleForegroundMessage);

    // handle background message (when app is closed)
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    // handle notifs when app is in background but reopened
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessageOpenedApp);
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('Background message message: ${message.notification?.title}');
    }

    // handle background message
    // still a todo
  }

  void handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Foreground message: ${message.notification?.title}');
    }

    // show notif overlay or play a sound
    // still a todo
  }

  void handleMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('App opened via notification: ${message.notification?.title}');
    }

    // navigate to relevant screen based on the messsage data
    // ex pseudo-code: if (message.data['type'] == 'chat') { navigate to chat }
    // still a todo
  }

  Future<String?> getToken() async {
    try {
      String? token = await messaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $token');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
      return null;
    }
  }
}