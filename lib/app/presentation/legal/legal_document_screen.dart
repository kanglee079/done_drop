import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:done_drop/core/constants/app_constants.dart';
import 'package:done_drop/core/constants/app_links.dart';
import 'package:done_drop/core/theme/theme.dart';

enum LegalDocumentType { privacyPolicy, termsOfService }

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({super.key, required this.documentType});

  final LegalDocumentType documentType;

  @override
  Widget build(BuildContext context) {
    final content = _contentFor(documentType);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: Get.back,
        ),
        title: Text(content.title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.space24,
          AppSizes.space12,
          AppSizes.space24,
          AppSizes.space40,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.space20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: AppSizes.borderRadiusLg,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title,
                  style: AppTypography.headlineSmall(
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSizes.space8),
                Text(
                  content.lastUpdated,
                  style: AppTypography.bodySmall(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSizes.space12),
                Text(
                  content.intro,
                  style: AppTypography.bodyMedium(color: AppColors.onSurface),
                ),
                const SizedBox(height: AppSizes.space16),
                Text(
                  content.publicUrlNote,
                  style: AppTypography.bodySmall(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.space20),
          for (final section in content.sections) ...[
            _LegalSection(heading: section.heading, body: section.body),
            const SizedBox(height: AppSizes.space16),
          ],
        ],
      ),
    );
  }

  _LegalDocumentContent _contentFor(LegalDocumentType type) {
    switch (type) {
      case LegalDocumentType.privacyPolicy:
        final url = AppLinks.hasPublicPrivacyPolicy
            ? AppLinks.privacyPolicyUrl
            : 'Deploy `web/legal/privacy.html` and set AppLinks.privacyPolicyUrl before store submission.';
        return _LegalDocumentContent(
          title: 'Privacy Policy',
          lastUpdated: 'Last updated: April 17, 2026',
          intro:
              '${AppConstants.appName} helps you track habits, capture proof moments, and share selectively with people you trust. This policy explains what data the app uses and why.',
          publicUrlNote: 'Public URL: $url',
          sections: const [
            _LegalSectionContent(
              heading: 'Information We Collect',
              body:
                  'We collect account details such as your email address and profile name, habit data you create, private proof moments you upload, friend relationships you approve, and device-level settings required to run reminders and media uploads.',
            ),
            _LegalSectionContent(
              heading: 'How We Use Data',
              body:
                  'We use your data to authenticate you, sync your habits and moments across devices, show your private feed and wall, send reminder notifications you enable, and keep the service reliable and secure.',
            ),
            _LegalSectionContent(
              heading: 'Sharing and Visibility',
              body:
                  'Your moments remain private by default. If you choose a friends visibility option, the app shares that moment only with the specific people allowed by the visibility setting you selected.',
            ),
            _LegalSectionContent(
              heading: 'Storage Providers',
              body:
                  'DoneDrop stores account and app data in Firebase services, including Authentication, Cloud Firestore, Storage, Analytics, and Crashlytics. Media files are stored separately from metadata.',
            ),
            _LegalSectionContent(
              heading: 'Account Deletion',
              body:
                  'You can initiate account deletion from the Me tab inside the app. Deleting your account removes your profile, habits, personal moments, and friend graph data, except records we must retain for legal compliance, fraud prevention, billing, or abuse handling.',
            ),
          ],
        );
      case LegalDocumentType.termsOfService:
        final url = AppLinks.hasPublicTerms
            ? AppLinks.termsOfServiceUrl
            : 'Deploy `web/legal/terms.html` and set AppLinks.termsOfServiceUrl before store submission.';
        return _LegalDocumentContent(
          title: 'Terms of Service',
          lastUpdated: 'Last updated: April 17, 2026',
          intro:
              'These terms govern your use of ${AppConstants.appName}. By creating an account or using the app, you agree to use the service responsibly and lawfully.',
          publicUrlNote: 'Public URL: $url',
          sections: const [
            _LegalSectionContent(
              heading: 'Your Account',
              body:
                  'You are responsible for the security of your account and for all activity that happens under it. Keep your sign-in method current and do not impersonate others.',
            ),
            _LegalSectionContent(
              heading: 'Acceptable Use',
              body:
                  'Do not use DoneDrop to harass, abuse, or expose private information about other people. Do not upload content you do not have permission to share.',
            ),
            _LegalSectionContent(
              heading: 'Private Social Features',
              body:
                  'Friend connections, proof moments, reactions, and reports are intended for private accountability. We may remove content or restrict access to protect users and enforce these terms.',
            ),
            _LegalSectionContent(
              heading: 'Billing and Premium',
              body:
                  'Any future premium subscription will be governed by the pricing, billing cycle, renewal terms, and cancellation options shown at purchase time through the applicable app store.',
            ),
            _LegalSectionContent(
              heading: 'Termination',
              body:
                  'You can stop using the service at any time. We may suspend or remove accounts that violate these terms, create security risks, or misuse private social features.',
            ),
          ],
        );
    }
  }
}

class _LegalSection extends StatelessWidget {
  const _LegalSection({required this.heading, required this.body});

  final String heading;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.space20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: AppTypography.titleMedium(color: AppColors.onSurface),
          ),
          const SizedBox(height: AppSizes.space8),
          Text(
            body,
            style: AppTypography.bodyMedium(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _LegalDocumentContent {
  const _LegalDocumentContent({
    required this.title,
    required this.lastUpdated,
    required this.intro,
    required this.publicUrlNote,
    required this.sections,
  });

  final String title;
  final String lastUpdated;
  final String intro;
  final String publicUrlNote;
  final List<_LegalSectionContent> sections;
}

class _LegalSectionContent {
  const _LegalSectionContent({required this.heading, required this.body});

  final String heading;
  final String body;
}
