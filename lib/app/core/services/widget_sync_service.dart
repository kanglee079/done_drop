import 'dart:convert';
import 'package:flutter/foundation.dart';
// import 'package:home_widget/home_widget.dart'; // To be added when native widgets are configured

/// Service responsible for serializing user progress and dispatching it to native iOS/Android widgets
class WidgetSyncService {
  
  static const String _appGroupId = 'group.com.donedrop.widget'; // Use your actual App Group ID
  static const String _widgetName = 'DoneDropWidget';

  /// Call this whenever a habit is completed or updated
  Future<void> syncProgress({
    required int completedToday,
    required int totalToday,
    required String nextHabitName,
  }) async {
    try {
      final widgetData = {
        'completed': completedToday,
        'total': totalToday,
        'nextHabit': nextHabitName,
        'progress': totalToday > 0 ? (completedToday / totalToday) : 0,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      // When home_widget is installed:
      // await HomeWidget.saveWidgetData<String>('widget_data', jsonEncode(widgetData));
      // await HomeWidget.updateWidget(name: _widgetName, iOSName: _widgetName);

      debugPrint('WidgetSyncService: Synchronized widget data: $widgetData');
    } catch (e) {
      debugPrint('WidgetSyncService Error: Failed to sync widget data: $e');
    }
  }
}
