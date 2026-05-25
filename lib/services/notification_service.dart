import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (_) {},
    );

    _initialized = true;
  }

  static Future<void> showNewMail({required int count, required String time}) async {
    const androidDetails = AndroidNotificationDetails(
      'supermini_mail',
      'Mail Notifications',
      channelDescription: 'Notifications for new mail arrivals',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      0,
      'New Mail Arrived',
      'Mail #$count received at $time',
      details,
    );
  }

  static Future<void> showConnectionStatus({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'supermini_connection',
      'Connection Status',
      channelDescription: 'Device connection status updates',
      importance: Importance.low,
      priority: Priority.low,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(1, title, body, details);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}