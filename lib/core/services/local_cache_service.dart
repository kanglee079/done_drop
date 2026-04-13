import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local-first caching layer using Hive.
/// Loads cached data immediately on startup so the UI is never blank.
/// Firestore data syncs in the background and updates the cache on change.
class LocalCacheService {
  LocalCacheService._();
  static LocalCacheService? _instance;
  static LocalCacheService get instance => _instance ??= LocalCacheService._();

  static const _actsKey = 'all';
  static const _syncKey = 'last_sync_timestamp';
  static const _todayKeyPrefix = 'instances_';

  Box<String>? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>('done_drop_cache');
  }

  // ── Activities ────────────────────────────────────────────────────────────

  Future<void> cacheActivities(List<Map<String, dynamic>> activities) async {
    await _box?.put(_actsKey, jsonEncode(activities));
    await _markSynced();
  }

  List<Map<String, dynamic>> loadCachedActivities() {
    try {
      final raw = _box?.get(_actsKey);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  // ── Activity Instances ─────────────────────────────────────────────────────

  Future<void> cacheTodayInstances(List<Map<String, dynamic>> instances) async {
    final key = _todayKey();
    await _box?.put(key, jsonEncode(instances));
    await _markSynced();
  }

  List<Map<String, dynamic>> loadCachedTodayInstances() {
    try {
      final raw = _box?.get(_todayKey());
      if (raw == null) return [];
      final list = jsonDecode(raw) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> invalidateTodayInstances() async {
    await _box?.delete(_todayKey());
  }

  String _todayKey() {
    final now = DateTime.now();
    return '$_todayKeyPrefix${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

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
