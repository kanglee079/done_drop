import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/firebase/repositories/circle_repository.dart';
import 'package:done_drop/core/models/circle.dart';
import 'package:done_drop/core/errors/result.dart';
import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';

/// DoneDrop Create Circle Screen
class CreateCircleScreen extends StatefulWidget {
  const CreateCircleScreen({super.key});

  @override
  State<CreateCircleScreen> createState() => _CreateCircleScreenState();
}

class _CreateCircleScreenState extends State<CreateCircleScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'close_friends';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createCircle() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final uid = Get.find<AuthController>().firebaseUser?.uid;
    if (uid == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'You must be signed in to create a circle';
      });
      return;
    }

    final circleRepo = Get.find<CircleRepository>();
    final now = DateTime.now();
    final circleId = 'circle_${now.millisecondsSinceEpoch}';

    final circle = Circle(
      id: circleId,
      name: _nameController.text.trim(),
      type: _selectedType,
      ownerId: uid,
      memberIds: [uid], // Owner is automatically a member
      createdAt: now,
      updatedAt: now,
    );

    final membership = CircleMembership(
      id: 'membership_${now.millisecondsSinceEpoch}',
      circleId: circleId,
      userId: uid,
      role: 'owner',
      joinedAt: now,
    );

    final result = await circleRepo.createCircleWithMembership(circle, membership);

    setState(() => _isLoading = false);

    result.fold(
      onSuccess: (_) {
        AnalyticsService.instance.circleCreated();
        Get.back();
        Get.snackbar(
          'Circle Created',
          'Your circle "${circle.name}" is ready',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      onFailure: (failure) {
        setState(() => _errorMessage = failure.toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        title: const Text('Create Circle'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.space24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CIRCLE NAME',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.outline,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: AppSizes.space8),
              DDTextField(
                controller: _nameController,
                label: 'Circle Name',
                hint: 'e.g. Sunday Collective',
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter a circle name'
                    : null,
              ),
              const SizedBox(height: AppSizes.space24),
              const Text(
                'CIRCLE TYPE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.outline,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: AppSizes.space12),
              Wrap(
                spacing: AppSizes.space8,
                children: [
                  _TypeChip(
                    label: 'Partner',
                    icon: Icons.favorite,
                    isSelected: _selectedType == 'partner',
                    onTap: () => setState(() => _selectedType = 'partner'),
                  ),
                  _TypeChip(
                    label: 'Close Friends',
                    icon: Icons.groups,
                    isSelected: _selectedType == 'close_friends',
                    onTap: () => setState(() => _selectedType = 'close_friends'),
                  ),
                  _TypeChip(
                    label: 'Squad',
                    icon: Icons.celebration,
                    isSelected: _selectedType == 'squad',
                    onTap: () => setState(() => _selectedType = 'squad'),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.space32),

              // Error message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSizes.space12),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: AppSizes.borderRadiusMd,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.error, size: 18),
                      const SizedBox(width: AppSizes.space8),
                      Expanded(
                        child: Text(_errorMessage!, style: TextStyle(color: AppColors.onErrorContainer, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.space16),
              ],

              DDPrimaryButton(
                label: 'Create Circle',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _createCircle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.space16,
          vertical: AppSizes.space8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryFixed : AppColors.surfaceContainerLow,
          borderRadius: AppSizes.borderRadiusFull,
          border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
