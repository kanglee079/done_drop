import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/presentation/recap/recap_controller.dart';
import 'package:done_drop/core/services/analytics_service.dart';

/// DoneDrop Weekly Recap Screen
class RecapScreen extends StatelessWidget {
  const RecapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RecapController>(
      init: RecapController(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.space24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                          onPressed: () => Get.back(),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.space12,
                            vertical: AppSizes.space4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.tertiaryFixed,
                            borderRadius: AppSizes.borderRadiusFull,
                          ),
                          child: Text(
                            ctrl.weekLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onTertiaryFixed,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.space24),
                    Text(
                      'Your Week in Moments',
                      style: TextStyle(
                        fontFamily: AppTypography.serifFamily,
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space8),
                    Text(
                      '"You\'re building a beautiful life,\none moment at a time."',
                      style: TextStyle(
                        fontFamily: AppTypography.serifFamily,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: AppColors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space48),
                    // Stats row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(AppSizes.space20),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: AppSizes.borderRadiusLg,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${ctrl.totalMoments}',
                                  style: TextStyle(
                                    fontFamily: AppTypography.serifFamily,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryContainer,
                                  ),
                                ),
                                Text(
                                  'MOMENTS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurfaceVariant,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.space16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(AppSizes.space20),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: AppSizes.borderRadiusLg,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${ctrl.streakDays}',
                                  style: TextStyle(
                                    fontFamily: AppTypography.serifFamily,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'DAY STREAK',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.space48),
                    // Day-by-day moments
                    if (ctrl.days.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.space32),
                          child: Column(
                            children: [
                              Icon(Icons.photo_camera_outlined,
                                  size: 48, color: AppColors.outline),
                              const SizedBox(height: AppSizes.space16),
                              Text(
                                'No moments this week yet.',
                                style: TextStyle(
                                  fontFamily: AppTypography.serifFamily,
                                  fontSize: 18,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...ctrl.days.map((day) => _DaySection(day: day)),
                    const SizedBox(height: AppSizes.space48),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.space20),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: AppColors.outlineVariant.withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Ready to share this story?',
                            style: TextStyle(
                              fontFamily: AppTypography.serifFamily,
                              fontSize: 22,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSizes.space16),
                          DDPrimaryButton(
                            label: 'Share with Circle',
                            icon: Icons.share,
                            onPressed: () {
                              AnalyticsService.instance.recapShared();
                              Get.snackbar(
                                'Coming soon',
                                'Sharing to circles is on the roadmap.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: AppColors.primaryContainer,
                                colorText: AppColors.onPrimaryContainer,
                              );
                            },
                            isExpanded: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({required this.day});
  final RecapDay day;

  String get _dayLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dayDate = DateTime(day.date.year, day.date.month, day.date.day);
    if (dayDate == today) return 'Today';
    if (dayDate == yesterday) return 'Yesterday';
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${days[dayDate.weekday - 1]}, ${months[dayDate.month - 1]} ${dayDate.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _dayLabel,
            style: TextStyle(
              fontFamily: AppTypography.serifFamily,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSizes.space12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: day.moments.length,
            itemBuilder: (ctx, i) {
              final m = day.moments[i];
              return ClipRRect(
                borderRadius: AppSizes.borderRadiusSm,
                child: CachedNetworkImage(
                  imageUrl: m.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.surfaceContainerHighest,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.surfaceContainerHighest,
                    child: const Icon(Icons.broken_image, size: 20),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
