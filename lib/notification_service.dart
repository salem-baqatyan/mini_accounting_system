import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
  }

  Future<void> requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  /// تذكيرات ثابتة يومية (9، 10، 11 مساءً) من السبت إلى الخميس
  Future<void> scheduleDailyReminders() async {
    const List<int> reminderHours = [21, 22, 23]; // 9، 10، 11 مساء
    const List<String> messages = [
      "لا تنسَ إدخال الإيرادات اليومية في نظام ورشة بايمين!",
      "هل سجلت المصروفات اليوم؟ نظام بايمين بانتظارك!",
      "تذكير أخير: أكمل إدخالاتك اليومية الآن 💼",
    ];

    const int baseId = 100000;

    for (
      int weekday = DateTime.saturday;
      weekday <= DateTime.thursday;
      weekday++
    ) {
      for (int i = 0; i < reminderHours.length; i++) {
        final scheduledDate = _nextInstanceOfWeekdayAndHour(
          weekday,
          reminderHours[i],
        );
        await flutterLocalNotificationsPlugin.zonedSchedule(
          baseId + weekday * 10 + i, // ID فريد لكل تذكير
          "📋 تذكير من ورشة بايمين",
          messages[i],
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'daily_reminder_channel',
              'Daily Reminders',
              channelDescription: 'Daily reminders for accounting tasks',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher', // تأكد من وجود الأيقونة في mipmap
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  /// حساب التاريخ القادم للتذكير في يوم معين وساعة معينة
  tz.TZDateTime _nextInstanceOfWeekdayAndHour(int weekday, int hour) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
    );

    while (scheduledDate.weekday != weekday || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}
