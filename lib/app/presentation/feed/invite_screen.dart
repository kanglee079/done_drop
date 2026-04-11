import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/presentation/feed/invite_controller.dart';

/// DoneDrop Invite Screen
class InviteScreen extends StatelessWidget {
  const InviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InviteController>(
      init: InviteController(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => Get.back(),
            ),
            title: const Text('Invite to Circle'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expand the Circle',
                  style: TextStyle(
                    fontFamily: AppTypography.serifFamily,
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSizes.space8),
                Text(
                  'Invite those who matter most.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSizes.space32),
                Obx(() {
                  if (ctrl.isLoading.value) {
                    return Container(
                      padding: const EdgeInsets.all(AppSizes.space32),
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(color: AppColors.primary),
                    );
                  }
                  return Container(
                    padding: const EdgeInsets.all(AppSizes.space20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: AppSizes.borderRadiusLg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'UNIQUE INVITE LINK',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryContainer,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: AppSizes.space12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.space16,
                            vertical: AppSizes.space12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: AppSizes.borderRadiusFull,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  ctrl.inviteCode.value.isEmpty
                                      ? 'Generating...'
                                      : 'donedrop.app/join/${ctrl.inviteCode.value}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.outline,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: ctrl.copyLink,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.space16,
                                    vertical: AppSizes.space8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: AppSizes.borderRadiusFull,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.copy, size: 16, color: Colors.white),
                                      SizedBox(width: 6),
                                      Text(
                                        'Copy',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSizes.space16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: ctrl.shareLinkNative,
                            icon: const Icon(Icons.share, size: 18),
                            label: const Text('Share Invite Link'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.all(AppSizes.space16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: AppSizes.space24),
                Text(
                  'Share this link with friends. Anyone with the link can join your circle.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.outline,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
