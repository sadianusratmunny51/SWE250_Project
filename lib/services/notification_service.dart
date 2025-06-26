import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Initialization
  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    // Initialize with tap callback
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("🔔 Notification tapped. Payload: ${response.payload}");
      },
    );

    // Explicitly create the channel
    final androidNotificationChannel = AndroidNotificationChannel(
      'task_channel_id',
      'Task Notifications',
      description: 'Task reminders notification channel',
      importance: Importance.max,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);

    // Request POST_NOTIFICATIONS on Android 13+
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        final status = await Permission.notification.status;
        print("🔐 Notification permission status: $status");
        if (!status.isGranted) {
          final result = await Permission.notification.request();
          print("🔐 Permission request result: $result");
        }
      }
    }
  }

  static Future<void> showImmediateTestNotification() async {
    print('🚨 Showing test notification immediately');
    await _notifications.show(
      999,
      "Visible in foreground",
      "This is an immediate test notification",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel_id',
          'Task Notifications',
          channelDescription: 'Task reminders notification channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Schedule a notification
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    print(
        '🔔 Scheduling notification: id=$id, title="$title", time=$scheduledTime');

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel_id',
          'Task Notifications',
          channelDescription: 'Task reminders notification channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      //allowWhileIdle: true, // <--- This is important!
    );

    print('✅ Notification scheduled!');
  }
}
