import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';

/// DoneDrop Profile Screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: const Center(
        child: DDEmptyState(
          title: 'Profile',
          description: 'Your profile settings will appear here.',
          icon: Icons.person_outline,
        ),
      ),
    );
  }
}
