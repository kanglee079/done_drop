import 'dart:ui';

import 'package:get/get.dart';

import '../../l10n/l10n.dart';
import '../models/user_profile.dart';
import 'storage_service.dart';

class LocaleController extends GetxController {
  LocaleController();

  static const _storageKey = 'preferred_locale_code';

  final Rxn<Locale> _selectedLocale = Rxn<Locale>();

  Locale? get locale => _selectedLocale.value;
  String get currentLanguageCode =>
      _selectedLocale.value?.languageCode ??
      resolveSupportedLocale(PlatformDispatcher.instance.locale).languageCode;

  bool get isVietnamese => currentLanguageCode == 'vi';

  Future<void> init() async {
    final savedCode = StorageService.instance.getString(_storageKey);
    if (savedCode == null || savedCode.isEmpty) return;
    _selectedLocale.value = Locale(savedCode);
  }

  Future<void> setLocaleCode(String code, {bool persistLocally = true}) async {
    final locale = Locale(code);
    _selectedLocale.value = locale;
    if (persistLocally) {
      await StorageService.instance.setString(_storageKey, code);
    }
    await Get.updateLocale(locale);
  }

  Future<void> syncFromProfile(UserProfile? profile) async {
    final preferredCode = profile?.settings.preferredLocaleCode;
    if (preferredCode == null || preferredCode.isEmpty) {
      return;
    }

    if (preferredCode == currentLanguageCode) {
      return;
    }

    await setLocaleCode(preferredCode);
  }
}
