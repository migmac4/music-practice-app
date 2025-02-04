import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

// Função estática para handler de background
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  SharedPreferences? _prefs;

  NotificationService._();

  Future<void> initialize() async {
    // Inicializa timezone apenas para conversão
    tz.initializeTimeZones();
    
    _prefs = await SharedPreferences.getInstance();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: [
        DarwinNotificationCategory(
          'daily_reminder',
          actions: [
            DarwinNotificationAction.plain(
              'MARK_AS_READ',
              'OK',
              options: {
                DarwinNotificationActionOption.foreground,
              },
            ),
          ],
          options: {
            DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
            DarwinNotificationCategoryOption.allowAnnouncement,
            DarwinNotificationCategoryOption.allowInCarPlay,
          },
        ),
      ],
    );

    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        if (details.actionId == 'MARK_AS_READ') {
          // A notificação foi lida/descartada pelo usuário
          print('Notification dismissed by user action');
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Solicita permissão de notificação no Android
    final androidPlatform = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlatform != null) {
      androidPlatform.requestNotificationsPermission();
    }
  }

  Future<bool> requestPermissions() async {
    // Removed debug print
    final platform = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (platform != null) {
      await platform.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    final androidPlatform = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlatform != null) {
      final hasPermission = await androidPlatform.requestExactAlarmsPermission() ?? false;
      return hasPermission;
    }

    return true;
  }

  Future<void> scheduleDailyReminder({
    required String title,
    required String body,
    required DateTime time,
  }) async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      return;
    }

    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }

    await _prefs!.setInt('reminder_hour', time.hour);
    await _prefs!.setInt('reminder_minute', time.minute);
    await _prefs!.setBool('reminder_enabled', true);

    final now = DateTime.now();
    
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      if (time.second == 0) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      } else {
        scheduledDate = time;
      }
    }

    final scheduledTZDate = tz.TZDateTime.from(scheduledDate, tz.local);

    final androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Practice Reminder',
      channelDescription: 'Reminds you to practice every day',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: const BigTextStyleInformation(''),
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
    );

    try {
      await _notifications.zonedSchedule(
        0,
        title,
        body,
        scheduledTZDate,
        NotificationDetails(
          android: androidDetails,
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
            interruptionLevel: InterruptionLevel.timeSensitive,
            categoryIdentifier: 'daily_reminder',
            threadIdentifier: 'daily_reminder',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // Keep error logging for debugging purposes
      print('ERROR: Failed to schedule notification: $e');
      print('ERROR Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> cancelDailyReminder() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    await _prefs!.setBool('reminder_enabled', false);
    await _notifications.cancel(0);
  }

  Future<bool> isReminderEnabled() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    return _prefs!.getBool('reminder_enabled') ?? false;
  }

  Future<DateTime?> getReminderTime() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    final hour = _prefs!.getInt('reminder_hour');
    final minute = _prefs!.getInt('reminder_minute');

    if (hour != null && minute != null) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    }
    return null;
  }
} 