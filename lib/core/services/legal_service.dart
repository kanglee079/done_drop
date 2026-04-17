import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/constants/app_links.dart';

class LegalService {
  LegalService._();

  static final LegalService instance = LegalService._();

  Future<void> openPrivacyPolicy() async {
    await _openExternalOrFallback(
      url: AppLinks.privacyPolicyUrl,
      fallbackRoute: AppRoutes.privacyPolicy,
    );
  }

  Future<void> openTermsOfService() async {
    await _openExternalOrFallback(
      url: AppLinks.termsOfServiceUrl,
      fallbackRoute: AppRoutes.termsOfService,
    );
  }

  Future<void> _openExternalOrFallback({
    required String url,
    required String fallbackRoute,
  }) async {
    if (url.startsWith('https://')) {
      final launched = await launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return;
    }

    if (Get.currentRoute != fallbackRoute) {
      await Get.toNamed(fallbackRoute);
    }
  }
}
