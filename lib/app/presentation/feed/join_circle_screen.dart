import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/firebase/repositories/circle_repository.dart';
import 'package:done_drop/core/models/circle.dart';
import 'package:done_drop/core/errors/result.dart';
import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';

/// DoneDrop Join Circle Screen
class JoinCircleScreen extends StatefulWidget {
  const JoinCircleScreen({super.key});

  @override
  State<JoinCircleScreen> createState() => _JoinCircleScreenState();
}

class _JoinCircleScreenState extends State<JoinCircleScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinCircle() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final uid = Get.find<AuthController>().firebaseUser?.uid;
    if (uid == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'You must be signed in';
      });
      return;
    }

    final code = _codeController.text.trim().toUpperCase();
    final circleRepo = Get.find<CircleRepository>();

    // 1. Find invite by code
    final invite = await circleRepo.getInviteByCode(code);

    if (invite == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid or expired invite code';
      });
      return;
    }

    if (!invite.isValid) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'This invite has expired or reached its limit';
      });
      return;
    }

    // 2. Get the circle to verify it exists
    final circle = await circleRepo.getCircle(invite.circleId);
    if (circle == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Circle no longer exists';
      });
      return;
    }

    if (circle.memberIds.contains(uid)) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'You are already a member of this circle';
      });
      return;
    }

    // 3. Add membership
    final now = DateTime.now();
    final membership = CircleMembership(
      id: 'membership_${now.millisecondsSinceEpoch}',
      circleId: circle.id,
      userId: uid,
      role: 'member',
      joinedAt: now,
    );

    // 4. Update circle's memberIds
    final updatedCircle = circle.copyWith(
      memberIds: [...circle.memberIds, uid],
      updatedAt: now,
    );

    final result = await circleRepo.joinCircleWithMembership(updatedCircle, membership, invite);

    setState(() => _isLoading = false);

    result.fold(
      onSuccess: (_) {
        AnalyticsService.instance.circleJoined(circle.id);
        Get.back();
        Get.snackbar(
          'Joined ${circle.name}',
          'You are now a member of the circle',
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
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        title: const Text('Join a Circle'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.space24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Invite Code',
                style: TextStyle(
                  fontFamily: AppTypography.serifFamily,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSizes.space8),
              Text(
                'Ask the circle owner for their invite code.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSizes.space32),
              DDTextField(
                controller: _codeController,
                label: 'Invite Code',
                hint: 'e.g. CIRCLE-X92K-L1',
                textCapitalization: TextCapitalization.characters,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter the invite code'
                    : null,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSizes.space12),
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
              ],
              const SizedBox(height: AppSizes.space32),
              DDPrimaryButton(
                label: 'Join Circle',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _joinCircle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
