import 'package:flutter/material.dart';

import '../models/activity.dart';

List<Activity> sortActivitiesBySchedule(Iterable<Activity> source) {
  final sorted = source.toList(growable: false);
  sorted.sort((left, right) {
    final reminderCompare = _reminderSortKey(
      left,
    ).compareTo(_reminderSortKey(right));
    if (reminderCompare != 0) return reminderCompare;

    final createdCompare = left.createdAt.compareTo(right.createdAt);
    if (createdCompare != 0) return createdCompare;
    return left.title.compareTo(right.title);
  });
  return sorted;
}

String formatReminderTimeValue(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

TimeOfDay parseReminderTime(
  String? value, {
  TimeOfDay fallback = const TimeOfDay(hour: 8, minute: 0),
}) {
  if (value == null || value.isEmpty) {
    return fallback;
  }

  final parts = value.split(':');
  if (parts.length != 2) {
    return fallback;
  }

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) {
    return fallback;
  }

  return TimeOfDay(hour: hour, minute: minute);
}

int _reminderSortKey(Activity activity) {
  if (!activity.hasReminder) return 9999;
  return (activity.reminderHour ?? 0) * 60 + (activity.reminderMinute ?? 0);
}
