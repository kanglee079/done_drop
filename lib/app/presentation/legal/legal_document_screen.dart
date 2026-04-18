import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/core/constants/app_constants.dart';
import 'package:done_drop/core/constants/app_links.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/l10n/l10n.dart';

enum LegalDocumentType { privacyPolicy, termsOfService }

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({super.key, required this.documentType});

  final LegalDocumentType documentType;

  @override
  Widget build(BuildContext context) {
    final content = _contentFor(documentType);
    final spec = DDResponsiveSpec.of(context);

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
      body: DDResponsiveCenter(
        maxWidth: 760,
        child: ListView(
          padding: spec.pagePadding(
            top: AppSizes.space12,
            bottom: AppSizes.space40,
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
      ),
    );
  }

  _LegalDocumentContent _contentFor(LegalDocumentType type) {
    final isVietnamese = Get.locale?.languageCode == 'vi';

    switch (type) {
      case LegalDocumentType.privacyPolicy:
        final url = AppLinks.hasPublicPrivacyPolicy
            ? AppLinks.privacyPolicyUrl
            : (isVietnamese
                  ? 'Hãy deploy `web/legal/privacy.html` và cấu hình AppLinks.privacyPolicyUrl trước khi submit store.'
                  : 'Deploy `web/legal/privacy.html` and set AppLinks.privacyPolicyUrl before store submission.');
        return _LegalDocumentContent(
          title: currentL10n.privacyPolicy,
          lastUpdated: isVietnamese
              ? 'Cập nhật lần cuối: 17 tháng 4, 2026'
              : 'Last updated: April 17, 2026',
          intro: isVietnamese
              ? '${AppConstants.appName} giúp bạn theo dõi thói quen, lưu khoảnh khắc bằng chứng và chia sẻ có chọn lọc với những người bạn tin tưởng. Chính sách này giải thích dữ liệu nào được sử dụng và vì sao.'
              : '${AppConstants.appName} helps you track habits, capture proof moments, and share selectively with people you trust. This policy explains what data the app uses and why.',
          publicUrlNote: isVietnamese
              ? 'URL công khai: $url'
              : 'Public URL: $url',
          sections: isVietnamese
              ? const [
                  _LegalSectionContent(
                    heading: 'Dữ liệu chúng tôi thu thập',
                    body:
                        'Chúng tôi thu thập thông tin tài khoản như email và tên hiển thị, dữ liệu thói quen bạn tạo, khoảnh khắc bằng chứng riêng tư bạn tải lên, các kết nối buddy bạn chấp thuận, cùng những tuỳ chọn thiết bị cần thiết để chạy nhắc nhở và tải media.',
                  ),
                  _LegalSectionContent(
                    heading: 'Cách chúng tôi sử dụng dữ liệu',
                    body:
                        'Dữ liệu được dùng để xác thực tài khoản, đồng bộ thói quen và khoảnh khắc giữa các thiết bị, hiển thị feed và wall riêng tư, gửi nhắc nhở nếu bạn bật, và giữ dịch vụ ổn định, an toàn.',
                  ),
                  _LegalSectionContent(
                    heading: 'Chia sẻ và hiển thị',
                    body:
                        'Khoảnh khắc của bạn mặc định là riêng tư. Nếu bạn chọn chế độ chia sẻ cho bạn bè, ứng dụng chỉ chia sẻ khoảnh khắc đó cho đúng những người được phép theo cài đặt hiển thị bạn đã chọn.',
                  ),
                  _LegalSectionContent(
                    heading: 'Nhà cung cấp lưu trữ',
                    body:
                        'DoneDrop lưu dữ liệu tài khoản và ứng dụng trên các dịch vụ Firebase, bao gồm Authentication, Cloud Firestore, Storage, Analytics và Crashlytics. Tệp media được lưu tách biệt khỏi metadata.',
                  ),
                  _LegalSectionContent(
                    heading: 'Xoá tài khoản',
                    body:
                        'Bạn có thể khởi tạo xoá tài khoản từ tab Me trong ứng dụng. Khi xoá, hồ sơ, thói quen, khoảnh khắc cá nhân và dữ liệu kết nối buddy của bạn sẽ bị xóa, trừ những bản ghi cần giữ lại vì yêu cầu pháp lý, chống gian lận, thanh toán hoặc xử lý lạm dụng.',
                  ),
                ]
              : const [
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
            : (isVietnamese
                  ? 'Hãy deploy `web/legal/terms.html` và cấu hình AppLinks.termsOfServiceUrl trước khi submit store.'
                  : 'Deploy `web/legal/terms.html` and set AppLinks.termsOfServiceUrl before store submission.');
        return _LegalDocumentContent(
          title: currentL10n.termsOfService,
          lastUpdated: isVietnamese
              ? 'Cập nhật lần cuối: 17 tháng 4, 2026'
              : 'Last updated: April 17, 2026',
          intro: isVietnamese
              ? 'Các điều khoản này điều chỉnh việc bạn sử dụng ${AppConstants.appName}. Khi tạo tài khoản hoặc dùng ứng dụng, bạn đồng ý sử dụng dịch vụ một cách có trách nhiệm và hợp pháp.'
              : 'These terms govern your use of ${AppConstants.appName}. By creating an account or using the app, you agree to use the service responsibly and lawfully.',
          publicUrlNote: isVietnamese
              ? 'URL công khai: $url'
              : 'Public URL: $url',
          sections: isVietnamese
              ? const [
                  _LegalSectionContent(
                    heading: 'Tài khoản của bạn',
                    body:
                        'Bạn chịu trách nhiệm cho tính an toàn của tài khoản và mọi hoạt động diễn ra dưới tài khoản đó. Hãy giữ phương thức đăng nhập luôn cập nhật và không được mạo danh người khác.',
                  ),
                  _LegalSectionContent(
                    heading: 'Cách sử dụng được chấp nhận',
                    body:
                        'Không được dùng DoneDrop để quấy rối, lạm dụng hoặc làm lộ thông tin riêng tư của người khác. Không tải lên nội dung mà bạn không có quyền chia sẻ.',
                  ),
                  _LegalSectionContent(
                    heading: 'Tính năng xã hội riêng tư',
                    body:
                        'Kết nối buddy, khoảnh khắc bằng chứng, reaction và báo cáo được thiết kế cho trách nhiệm riêng tư. Chúng tôi có thể gỡ nội dung hoặc hạn chế truy cập để bảo vệ người dùng và thực thi các điều khoản này.',
                  ),
                  _LegalSectionContent(
                    heading: 'Thanh toán và Premium',
                    body:
                        'Mọi gói premium trong tương lai sẽ tuân theo mức giá, chu kỳ thanh toán, điều khoản gia hạn và cách huỷ được hiển thị tại thời điểm mua qua cửa hàng ứng dụng tương ứng.',
                  ),
                  _LegalSectionContent(
                    heading: 'Chấm dứt',
                    body:
                        'Bạn có thể ngừng sử dụng dịch vụ bất cứ lúc nào. Chúng tôi có thể tạm ngưng hoặc xoá tài khoản vi phạm điều khoản, tạo rủi ro bảo mật hoặc lạm dụng các tính năng xã hội riêng tư.',
                  ),
                ]
              : const [
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
