import 'dart:ui';

import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import 'package:done_drop/l10n/app_localizations.dart';

extension BuildContextL10n on BuildContext {
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ??
      lookupAppLocalizations(
        resolveSupportedLocale(Localizations.maybeLocaleOf(this)),
      );
}

AppLocalizations get currentL10n {
  final context = Get.context;
  if (context != null) {
    return context.l10n;
  }

  final locale = PlatformDispatcher.instance.locale;
  return lookupAppLocalizations(_supportedLocale(locale));
}

Locale resolveSupportedLocale(Locale? deviceLocale) =>
    _supportedLocale(deviceLocale ?? PlatformDispatcher.instance.locale);

Locale _supportedLocale(Locale locale) {
  switch (locale.languageCode) {
    case 'vi':
      return const Locale('vi');
    default:
      return const Locale('en');
  }
}
