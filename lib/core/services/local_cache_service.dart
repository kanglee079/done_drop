import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local-first caching layer using Hive.
/// Loads cached data immediately on startup so the UI is never blank.
/// Firestore data syncs in the background and updates the cache on change.
class LocalCacheService {
  LocalCacheService._();
  static LocalCacheService? _instance;
  static LocalCacheService get instance => _instance ??= LocalCacheService._();

  static const _activitiesKeyPrefix = 'activities_';
  static const _syncKey = 'last_sync_timestamp';
  static const _todayKeyPrefix = 'instances_';
  static const _feedKeyPrefix = 'feed_';

  Box<String>? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>('done_drop_cache');
  }

  // ── Activities ────────────────────────────────────────────────────────────

  Future<void> cacheActivities(
    String userId,
    List<Map<String, dynamic>> activities,
  ) async {
    await _box?.put(activitiesKeyForUser(userId), jsonEncode(activities));
    await _markSynced();
  }

  List<Map<String, dynamic>> loadCachedActivities(String userId) {
    try {
      final raw = _box?.get(activitiesKeyForUser(userId));
      if (raw == null) return [];
      final list = jsonDecode(raw) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  // ── Activity Instances ─────────────────────────────────────────────────────

  Future<void> cacheTodayInstances(
    String userId,
    List<Map<String, dynamic>> instances,
  ) async {
    final key = todayKeyForUser(userId);
    await _box?.put(key, jsonEncode(instances));
    await _markSynced();
  }

  List<Map<String, dynamic>> loadCachedTodayInstances(String userId) {
    try {
      final raw = _box?.get(todayKeyForUser(userId));
      if (raw == null) return [];
      final list = jsonDecode(raw) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> invalidateTodayInstances(String userId) async {
    await _box?.delete(todayKeyForUser(userId));
  }

  // ── Buddy Feed ────────────────────────────────────────────────────────────

  Future<void> cacheFeedDeliveries(
    String userId,
    List<Map<String, dynamic>> deliveries,
  ) async {
    await _box?.put(_feedKey(userId), jsonEncode(deliveries));
    await _markSynced();
  }

  List<Map<String, dynamic>> loadCachedFeedDeliveries(String userId) {
    try {
      final raw = _box?.get(_feedKey(userId));
      if (raw == null) return [];
      final list = jsonDecode(raw) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> invalidateFeedDeliveries(String userId) async {
    await _box?.delete(_feedKey(userId));
  }

  @visibleForTesting
  static String activitiesKeyForUser(String userId) =>
      '$_activitiesKeyPrefix$userId';

  @visibleForTesting
  static String todayKeyForUser(
    String userId, {
    DateTime? now,
  }) {
    final resolvedNow = now ?? DateTime.now();
    return '$_todayKeyPrefix${userId}_${resolvedNow.year}-${resolvedNow.month.toString().padLeft(2, '0')}-${resolvedNow.day.toString().padLeft(2, '0')}';
  }

  String _feedKey(String userId) => '$_feedKeyPrefix$userId';

  // ── Sync tracking ─────────────────────────────────────────────────────────

  Future<void> _markSynced() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_syncKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<DateTime?> getLastSyncTime() async {
    final sp = await SharedPreferences.getInstance();
    final ts = sp.getInt(_syncKey);
    if (ts == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ts);
  }

  /// Returns true if local cache is stale (>5 min old).
  Future<bool> isCacheStale() async {
    final lastSync = await getLastSyncTime();
    if (lastSync == null) return true;
    return DateTime.now().difference(lastSync).inMinutes > 5;
  }

  /// Clear all caches (e.g. on sign-out).
  Future<void> clearAll() async {
    await _box?.clear();
  }
}
