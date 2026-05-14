import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static Future init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await notifications.initialize(settings);
  }

  static Future showNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'habit_channel',
      'Habit Reminders',

      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await notifications.show(
      0,
      'Momentum Reminder 🔥',
      'Don’t forget today’s habits!',
      details,
    );
  }

  static Future scheduleDailyNotification({
    required int hour,
    required int minute,
  }) async {
    await showNotification();
  }
}
