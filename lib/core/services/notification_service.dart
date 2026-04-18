import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:done_drop/core/models/activity.dart';
import 'package:done_drop/core/services/storage_service.dart';

class NotificationPermissionSnapshot {
  const NotificationPermissionSnapshot({
    required this.notificationsEnabled,
    required this.exactAlarmsEnabled,
    required this.scheduledReminderCount,
  });

  final bool notificationsEnabled;
  final bool exactAlarmsEnabled;
  final int scheduledReminderCount;
}

/// DoneDrop Notification Service
class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    await _configureLocalTimezone();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<bool> requestPermission({bool requestExactAlarms = false}) async {
    await init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final iOS = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      if (requestExactAlarms) {
        final canScheduleExact =
            await android.canScheduleExactNotifications() ?? false;
        if (!canScheduleExact) {
          await android.requestExactAlarmsPermission();
        }
      }
      return granted ?? false;
    }
    if (iOS != null) {
      final granted = await iOS.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return false;
  }

  // ── Reminder ─────────────────────────────────────────────────────────────
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    String? title,
    String? body,
  }) async {
    final scheduleMode = await _preferredScheduleMode();
    await _plugin.zonedSchedule(
      1,
      title ?? 'Time to reflect',
      body ?? 'Capture your moment of the day.',
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminders',
          channelDescription: 'Gentle nudges to capture your day.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: scheduleMode,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(1);
  }

  // ── Weekly Recap ─────────────────────────────────────────────────────────
  Future<void> scheduleWeeklyRecap({
    required int dayOfWeek,
    required int hour,
    required int minute,
  }) async {
    final scheduleMode = await _preferredScheduleMode();
    await _plugin.zonedSchedule(
      2,
      'Your Week in Moments',
      'Your weekly recap is ready to view.',
      _nextInstanceOfWeekday(dayOfWeek, hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_recap',
          'Weekly Recaps',
          channelDescription: 'Weekly reflection summaries.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: scheduleMode,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelWeeklyRecap() async {
    await _plugin.cancel(2);
  }

  // ── Task Reminders ──────────────────────────────────────────────────────
  Future<void> syncActivityReminders(Iterable<Activity> activities) async {
    await init();

    if (!_areHabitRemindersEnabled) {
      await cancelAllActivityReminders();
      return;
    }

    final desiredIds = <int>{};
    for (final activity in activities) {
      if (!activity.hasReminder || activity.isArchived) continue;
      final notificationId = _notificationIdForActivity(activity.id);
      desiredIds.add(notificationId);
      await scheduleActivityReminder(activity);
    }

    final pending = await _plugin.pendingNotificationRequests();
    for (final request in pending) {
      if (!_isActivityReminderPayload(request.payload)) continue;
      if (!desiredIds.contains(request.id)) {
        await _plugin.cancel(request.id);
      }
    }
  }

  Future<void> scheduleActivityReminder(Activity activity) async {
    await init();
    if (!_areHabitRemindersEnabled ||
        !activity.hasReminder ||
        activity.reminderHour == null ||
        activity.reminderMinute == null ||
        activity.isArchived) {
      await cancelActivityReminder(activity.id);
      return;
    }

    final scheduleMode = await _preferredScheduleMode();
    await _plugin.zonedSchedule(
      _notificationIdForActivity(activity.id),
      activity.title,
      'Đến giờ thực hiện rồi.',
      _nextInstanceOfTime(activity.reminderHour!, activity.reminderMinute!),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'activity_reminders',
          'Task Reminders',
          channelDescription:
              'Notifications that follow the exact reminder time of each task.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'activity:${activity.id}',
      androidScheduleMode: scheduleMode,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelActivityReminder(String activityId) async {
    await _plugin.cancel(_notificationIdForActivity(activityId));
  }

  Future<void> cancelAllActivityReminders() async {
    await init();
    final pending = await _plugin.pendingNotificationRequests();
    for (final request in pending) {
      if (_isActivityReminderPayload(request.payload)) {
        await _plugin.cancel(request.id);
      }
    }
  }

  // ── Circle Activity ─────────────────────────────────────────────────────
  Future<void> showCircleActivityNotification({
    required String circleName,
    required String userName,
    String? body,
  }) async {
    await init();
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '$userName shared a moment',
      body ?? 'in $circleName',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'circle_activity',
          'Circle Activity',
          channelDescription:
              'Notifications when circle members share moments.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<NotificationPermissionSnapshot> getPermissionSnapshot() async {
    await init();

    var notificationsEnabled = true;
    var exactAlarmsEnabled = !Platform.isAndroid;

    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      notificationsEnabled = await android?.areNotificationsEnabled() ?? false;
      exactAlarmsEnabled =
          await android?.canScheduleExactNotifications() ?? false;
    }

    final pending = await _plugin.pendingNotificationRequests();
    final scheduledReminderCount = pending
        .where((request) => _isActivityReminderPayload(request.payload))
        .length;

    return NotificationPermissionSnapshot(
      notificationsEnabled: notificationsEnabled,
      exactAlarmsEnabled: exactAlarmsEnabled,
      scheduledReminderCount: scheduledReminderCount,
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────
  bool get _areHabitRemindersEnabled =>
      StorageService.instance.getBool('pref_moment_reminders') ?? true;

  Future<void> _configureLocalTimezone() async {
    try {
      final currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  Future<AndroidScheduleMode> _preferredScheduleMode() async {
    if (!Platform.isAndroid) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }
    final canScheduleExact =
        await android.canScheduleExactNotifications() ?? false;
    return canScheduleExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  bool _isActivityReminderPayload(String? payload) =>
      payload != null && payload.startsWith('activity:');

  int _notificationIdForActivity(String activityId) {
    var hash = 2166136261;
    for (final codeUnit in activityId.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 16777619) & 0x7fffffff;
    }
    return 10000 + hash;
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextInstanceOfWeekday(int dayOfWeek, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (scheduled.weekday != dayOfWeek || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
