import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/app/presentation/home/home_controller.dart';
import 'package:done_drop/core/services/storage_service.dart';
import 'package:done_drop/core/services/notification_service.dart';
import 'package:done_drop/l10n/l10n.dart';

/// Controller for notification scheduling.
/// Manages daily reminder time and day-of-week toggles.
class NotificationController extends GetxController {
  NotificationController();

  StorageService get _storage => StorageService.instance;
  NotificationService get _notifService => NotificationService.instance;

  // Daily reminder
  final RxBool reminderEnabled = true.obs;
  final RxInt reminderHour = 20.obs; // 8 PM default
  final RxInt reminderMinute = 0.obs;

  // Weekly recap
  final RxBool recapEnabled = true.obs;
  final RxInt recapDay = DateTime.sunday.obs; // Sunday
  final RxInt recapHour = 10.obs; // 10 AM
  final RxInt recapMinute = 0.obs;

  // Selected day toggles (Mon-Sun)
  final RxList<bool> activeDays = <bool>[
    true,
    true,
    true,
    true,
    true,
    true,
    false,
  ].obs;

  String get reminderTimeLabel {
    final localizations = Get.context != null
        ? MaterialLocalizations.of(Get.context!)
        : null;
    return localizations?.formatTimeOfDay(
          TimeOfDay(hour: reminderHour.value, minute: reminderMinute.value),
          alwaysUse24HourFormat: false,
        ) ??
        '${reminderHour.value}:${reminderMinute.value.toString().padLeft(2, '0')}';
  }

  @override
  void onInit() {
    super.onInit();
    _loadPrefs();
  }

  void _loadPrefs() {
    reminderEnabled.value = _storage.getBool('notif_reminder_enabled') ?? true;
    reminderHour.value = _storage.getInt('notif_reminder_hour') ?? 20;
    reminderMinute.value = _storage.getInt('notif_reminder_minute') ?? 0;
    recapEnabled.value = _storage.getBool('notif_recap_enabled') ?? true;
    recapDay.value = _storage.getInt('notif_recap_day') ?? DateTime.sunday;
    recapHour.value = _storage.getInt('notif_recap_hour') ?? 10;
    recapMinute.value = _storage.getInt('notif_recap_minute') ?? 0;
    final daysStr = _storage.getString('notif_active_days');
    if (daysStr != null) {
      activeDays.value = daysStr.split(',').map((s) => s == '1').toList();
      if (activeDays.length != 7) {
        activeDays.value = [true, true, true, true, true, true, false];
      }
    }
  }

  Future<void> _saveReminderPrefs() async {
    await _storage.setBool('notif_reminder_enabled', reminderEnabled.value);
    await _storage.setInt('notif_reminder_hour', reminderHour.value);
    await _storage.setInt('notif_reminder_minute', reminderMinute.value);
  }

  Future<void> _saveRecapPrefs() async {
    await _storage.setBool('notif_recap_enabled', recapEnabled.value);
    await _storage.setInt('notif_recap_day', recapDay.value);
    await _storage.setInt('notif_recap_hour', recapHour.value);
    await _storage.setInt('notif_recap_minute', recapMinute.value);
  }

  void toggleReminderEnabled(bool value) {
    reminderEnabled.value = value;
    _saveReminderPrefs();
    if (value) {
      _scheduleReminder();
    } else {
      _notifService.cancelDailyReminder();
    }
  }

  Future<void> pickReminderTime() async {
    final time = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay(
        hour: reminderHour.value,
        minute: reminderMinute.value,
      ),
    );
    if (time != null) {
      reminderHour.value = time.hour;
      reminderMinute.value = time.minute;
      await _saveReminderPrefs();
      if (reminderEnabled.value) _scheduleReminder();
    }
  }

  void _scheduleReminder() {
    _notifService.scheduleDailyReminder(
      hour: reminderHour.value,
      minute: reminderMinute.value,
    );
  }

  void toggleRecapEnabled(bool value) {
    recapEnabled.value = value;
    _saveRecapPrefs();
    if (value) {
      _scheduleRecap();
    } else {
      _notifService.cancelWeeklyRecap();
    }
  }

  Future<void> pickRecapDay() async {
    // Simple day picker using a dialog
    final days = [
      currentL10n.dayMonShort,
      currentL10n.dayTueShort,
      currentL10n.dayWedShort,
      currentL10n.dayThuShort,
      currentL10n.dayFriShort,
      currentL10n.daySatShort,
      currentL10n.daySunShort,
    ];
    final picked = await Get.dialog<int>(
      AlertDialog(
        title: Text(currentL10n.selectDayTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(7, (i) {
            final dow = (i + 1); // Mon=1 ... Sun=7
            return ListTile(
              title: Text(days[i]),
              trailing: recapDay.value == dow
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () => Get.back(result: dow),
            );
          }),
        ),
      ),
    );
    if (picked != null) {
      recapDay.value = picked;
      _saveRecapPrefs();
      if (recapEnabled.value) _scheduleRecap();
    }
  }

  Future<void> pickRecapTime() async {
    final time = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay(hour: recapHour.value, minute: recapMinute.value),
    );
    if (time != null) {
      recapHour.value = time.hour;
      recapMinute.value = time.minute;
      await _saveRecapPrefs();
      if (recapEnabled.value) _scheduleRecap();
    }
  }

  void _scheduleRecap() {
    _notifService.scheduleWeeklyRecap(
      dayOfWeek: recapDay.value,
      hour: recapHour.value,
      minute: recapMinute.value,
    );
  }

  String get recapDayLabel {
    final days = [
      currentL10n.dayMonShort,
      currentL10n.dayTueShort,
      currentL10n.dayWedShort,
      currentL10n.dayThuShort,
      currentL10n.dayFriShort,
      currentL10n.daySatShort,
      currentL10n.daySunShort,
    ];
    return days[(recapDay.value - 1) % 7];
  }

  String get recapTimeLabel {
    final localizations = Get.context != null
        ? MaterialLocalizations.of(Get.context!)
        : null;
    return localizations?.formatTimeOfDay(
          TimeOfDay(hour: recapHour.value, minute: recapMinute.value),
          alwaysUse24HourFormat: false,
        ) ??
        '${recapHour.value}:${recapMinute.value.toString().padLeft(2, '0')}';
  }

  Future<void> requestPermissions() async {
    await _notifService.requestPermission();
    if (reminderEnabled.value) {
      _scheduleReminder();
    }
    if (recapEnabled.value) {
      _scheduleRecap();
    }
    if (Get.isRegistered<HomeController>()) {
      await _notifService.syncActivityReminders(
        Get.find<HomeController>().activities,
      );
    }
    final snapshot = await _notifService.getPermissionSnapshot();
    if (!snapshot.notificationsEnabled) {
      Get.snackbar(
        currentL10n.notificationSettingsTitle,
        currentL10n.notificationPermissionOffSubtitle,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
  }
}
