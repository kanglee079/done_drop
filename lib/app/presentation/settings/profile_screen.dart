import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/app/presentation/settings/profile_controller.dart';
import 'package:done_drop/l10n/l10n.dart';

/// DoneDrop Profile Screen — view and edit profile.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GetBuilder<ProfileController>(
      init: ProfileController(),
      builder: (ctrl) {
        return DismissKeyboard(
          child: Scaffold(
            backgroundColor: AppColors.surface,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () => Get.back(),
              ),
              title: Text(l10n.profileTitle),
              centerTitle: true,
              actions: [
                Obx(
                  () => TextButton(
                    onPressed: ctrl.isSaving.value ? null : ctrl.saveProfile,
                    child: ctrl.isSaving.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Text(
                            l10n.saveAction,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            body: DDResponsiveScrollBody(
              maxWidth: 560,
              child: Column(
                children: [
                  // Avatar
                  Obx(() {
                    final avatarUrl = ctrl.profile.value?.avatarUrl;
                    return GestureDetector(
                      onTap: ctrl.pickAndUploadAvatar,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 52,
                            backgroundColor: AppColors.primaryFixed,
                            backgroundImage: avatarUrl != null
                                ? CachedNetworkImageProvider(avatarUrl)
                                : null,
                            child: avatarUrl == null
                                ? const Icon(
                                    Icons.person,
                                    color: AppColors.primary,
                                    size: 48,
                                  )
                                : null,
                          ),
                          if (ctrl.isUploadingAvatar.value)
                            Positioned.fill(
                              child: CircleAvatar(
                                backgroundColor: Colors.black38,
                                child: const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.surface,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: AppSizes.space8),
                  Obx(() {
                    final msg = ctrl.successMessage.value;
                    if (msg == null) return const SizedBox.shrink();
                    return Text(
                      msg,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }),
                  const SizedBox(height: AppSizes.space24),

                  // User Code
                  Obx(() {
                    final code = ctrl.userCode;
                    if (code == null || code.isEmpty) return const SizedBox.shrink();
                    return GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.myCode),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: AppSizes.space20),
                        padding: const EdgeInsets.all(AppSizes.space16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          borderRadius: AppSizes.borderRadiusMd,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.qr_code_rounded, color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: AppSizes.space12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.myCodeTitle,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary.withValues(alpha: 0.7),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    code,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 4,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary.withValues(alpha: 0.5), size: 16),
                          ],
                        ),
                      ),
                    );
                  }),

                  // Name
                  _FieldSection(
                    label: l10n.profileFieldDisplayName,
                    child: TextField(
                      controller: ctrl.nameController,
                      decoration: _inputDecoration(l10n.profileNameHint),
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.space20),

                  // Bio
                  _FieldSection(
                    label: l10n.profileFieldBio,
                    child: TextField(
                      controller: ctrl.bioController,
                      maxLines: 3,
                      maxLength: 150,
                      decoration: _inputDecoration(l10n.profileBioHint),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),

                  // Error
                  Obx(() {
                    final msg = ctrl.errorMessage.value;
                    if (msg == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSizes.space12),
                      child: Text(
                        msg,
                        style: TextStyle(color: AppColors.error, fontSize: 12),
                      ),
                    );
                  }),

                  const SizedBox(height: AppSizes.space48),

                  // Danger zone
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.space16),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer.withValues(alpha: 0.3),
                      borderRadius: AppSizes.borderRadiusMd,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.dangerZoneLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: AppSizes.space12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: ctrl.deleteAccount,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: BorderSide(color: AppColors.error),
                            ),
                            child: Text(l10n.deleteAccountTitle),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: AppColors.outline.withValues(alpha: 0.5)),
    filled: true,
    fillColor: AppColors.surfaceContainerHighest,
    border: OutlineInputBorder(
      borderRadius: AppSizes.borderRadiusMd,
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.all(AppSizes.space16),
  );
}

class _FieldSection extends StatelessWidget {
  const _FieldSection({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.outline,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppSizes.space8),
        child,
      ],
    );
  }
}
