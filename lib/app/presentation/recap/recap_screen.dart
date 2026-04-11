import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';

/// DoneDrop Weekly Recap Screen
class RecapScreen extends StatelessWidget {
  const RecapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
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
                      'October 14 — 20',
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
                  fontFamily: 'Newsreader',
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: AppSizes.space8),
              Text(
                '"You\'re building a beautiful life,\none moment at a time."',
                style: TextStyle(
                  fontFamily: 'Newsreader',
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
                            '12',
                            style: TextStyle(
                              fontFamily: 'Newsreader',
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
                            '7',
                            style: TextStyle(
                              fontFamily: 'Newsreader',
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
                        fontFamily: 'Newsreader',
                        fontSize: 22,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space16),
                    DDPrimaryButton(
                      label: 'Share with Circle',
                      icon: Icons.share,
                      onPressed: () {},
                      isExpanded: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
