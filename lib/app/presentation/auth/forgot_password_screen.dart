import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/core/services/analytics_service.dart';

/// Forgot Password Screen — sends a password reset email via Firebase Auth.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailCtrl.text.trim(),
      );
      AnalyticsService.instance.passwordResetRequested();
      if (mounted) {
        setState(() => _emailSent = true);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _error = _friendlyError(e.code));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      default:
        return 'Unable to send reset email. Please try again.';
    }
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
      ),
      body: SafeArea(
        child: _emailSent ? _buildSuccessState() : _buildFormState(),
      ),
    );
  }

  Widget _buildSuccessState() {
    return DDResponsiveScrollBody(
      maxWidth: 520,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.tertiaryFixed,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.email_outlined,
                size: 40,
                color: AppColors.tertiary,
              ),
            ),
            const SizedBox(height: AppSizes.space32),
            Text(
              'Check Your Email',
              style: TextStyle(
                fontFamily: AppTypography.serifFamily,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            Text(
              'We sent a password reset link to\n${_emailCtrl.text.trim()}.\nCheck your inbox and spam folder.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSizes.space48),
            DDPrimaryButton(
              label: 'Back to Sign In',
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormState() {
    return DDResponsiveScrollBody(
      maxWidth: 520,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reset Password',
              style: TextStyle(
                fontFamily: AppTypography.serifFamily,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSizes.space8),
            Text(
              'Enter your email and we\'ll send you a link to reset your password.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSizes.space40),
            DDTextField(
              controller: _emailCtrl,
              label: 'Email',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter your email';
                if (!GetUtils.isEmail(v)) return 'Please enter a valid email';
                return null;
              },
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _sendResetEmail(),
            ),
            if (_error != null) ...[
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
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: AppColors.onErrorContainer,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSizes.space32),
            DDPrimaryButton(
              label: 'Send Reset Link',
              onPressed: _isLoading ? null : _sendResetEmail,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
