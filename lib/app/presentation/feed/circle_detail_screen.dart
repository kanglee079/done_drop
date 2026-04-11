import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme.dart';
import '../../routes/app_routes.dart';
import '../../core/widgets/widgets.dart';

/// DoneDrop Circle Detail Screen
class CircleDetailScreen extends StatelessWidget {
  const CircleDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'The Sunday Collective',
          style: TextStyle(
            fontFamily: 'Newsreader',
            fontSize: 18,
            fontStyle: FontStyle.italic,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined, color: AppColors.primary),
            onPressed: () => Get.toNamed(AppRoutes.invite, parameters: {'circleId': 'demo'}),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The Sunday Collective',
              style: TextStyle(
                fontFamily: 'Newsreader',
                fontSize: 36,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.space8),
            Text(
              'A private sanctuary for our weekly reflections, slow mornings, and the quiet moments that define us.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: AppSizes.space24),
            const DDEmptyState(
              title: 'No moments yet',
              description: 'Be the first to share a moment with this circle.',
              icon: Icons.photo_camera_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
