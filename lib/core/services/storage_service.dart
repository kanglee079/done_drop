import 'package:shared_preferences/shared_preferences.dart';

/// DoneDrop Local Storage Service using SharedPreferences
class StorageService {
  StorageService._();
  static StorageService get instance => StorageService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    if (_prefs == null) {
      throw StateError('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // ── String ────────────────────────────────────────────────────────────────
  String? getString(String key) => _p.getString(key);

  Future<bool> setString(String key, String value) => _p.setString(key, value);

  // ── Bool ─────────────────────────────────────────────────────────────────
  bool? getBool(String key) => _p.getBool(key);

  Future<bool> setBool(String key, bool value) => _p.setBool(key, value);

  // ── Int ─────────────────────────────────────────────────────────────────
  int? getInt(String key) => _p.getInt(key);

  Future<bool> setInt(String key, int value) => _p.setInt(key, value);

  // ── Remove ──────────────────────────────────────────────────────────────
  Future<bool> remove(String key) => _p.remove(key);

  Future<bool> clear() => _p.clear();

  bool containsKey(String key) => _p.containsKey(key);

  // ── Onboarding ──────────────────────────────────────────────────────────
  bool get isOnboardingComplete => getBool('onboarding_complete') ?? false;

  Future<bool> setOnboardingComplete(bool value) =>
      setBool('onboarding_complete', value);

  // ── Auth ─────────────────────────────────────────────────────────────────
  String? get userId => getString('user_id');
  Future<bool> setUserId(String? value) async {
    if (value == null) return remove('user_id');
    return setString('user_id', value);
  }

  // ── Premium ──────────────────────────────────────────────────────────────
  bool get isPremium => getBool('is_premium') ?? false;
  Future<bool> setPremium(bool value) => setBool('is_premium', value);

  // ── Theme ───────────────────────────────────────────────────────────────
  String get themeMode => getString('theme_mode') ?? 'system';
  Future<bool> setThemeMode(String mode) => setString('theme_mode', mode);
}
