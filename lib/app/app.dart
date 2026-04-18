import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:done_drop/l10n/app_localizations.dart';
import '../core/theme/theme.dart';
import '../l10n/l10n.dart';
import 'routes/app_pages.dart';
import '../core/services/locale_controller.dart';

/// DoneDrop App — Root widget
class DoneDropApp extends StatelessWidget {
  const DoneDropApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = Get.isRegistered<LocaleController>()
        ? Get.find<LocaleController>()
        : null;

    // System UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    if (localeController == null) {
      return _buildApp(locale: null);
    }

    return Obx(() => _buildApp(locale: localeController.locale));
  }

  GetMaterialApp _buildApp({required Locale? locale}) {
    return GetMaterialApp(
      title: 'DoneDrop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) =>
          resolveSupportedLocale(locale),
    );
  }
}
