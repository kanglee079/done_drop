import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/services/storage_service.dart';
import 'package:done_drop/core/services/notification_service.dart';

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
    true, true, true, true, true, true, false,
  ].obs;

  String get reminderTimeLabel {
    final h = reminderHour.value;
    final m = reminderMinute.value;
    final period = h >= 12 ? 'PM' : 'AM';
    final displayH = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$displayH:${m.toString().padLeft(2, '0')} $period';
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
      initialTime: TimeOfDay(hour: reminderHour.value, minute: reminderMinute.value),
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
    final days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    final picked = await Get.dialog<int>(
      AlertDialog(
        title: const Text('Select Day'),
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
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return days[(recapDay.value - 1) % 7];
  }

  String get recapTimeLabel {
    final h = recapHour.value;
    final m = recapMinute.value;
    final period = h >= 12 ? 'PM' : 'AM';
    final displayH = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$displayH:${m.toString().padLeft(2, '0')} $period';
  }

  Future<void> requestPermissions() async {
    await _notifService.requestPermission();
  }
}
