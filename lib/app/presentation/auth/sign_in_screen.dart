import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/features/auth/presentation/controllers/sign_in_controller.dart';

class SignInScreen extends GetView<SignInController> {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSizes.space64),
              // Logo & tagline
              Center(
                child: Text(
                  'DoneDrop',
                  style: TextStyle(
                    fontFamily: AppTypography.serifFamily,
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.space8),
              Center(
                child: Text(
                  'Complete it. Capture it.\nShare the moment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.space48),

              // Form
              Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    Obx(() => DDTextField(
                          controller: controller.emailController,
                          label: 'Email',
                          hint: 'you@example.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: controller.validateEmail,
                          textInputAction: TextInputAction.next,
                          enabled: !controller.isLoading.value,
                        )),
                    const SizedBox(height: AppSizes.space16),
                    Obx(() => DDTextField(
                          controller: controller.passwordController,
                          label: 'Password',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outlined,
                          obscureText: !controller.isPasswordVisible.value,
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordVisible.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.onSurfaceVariant,
                              size: 20,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                          validator: controller.validatePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => controller.signInWithEmail(),
                          enabled: !controller.isLoading.value,
                        )),
                  ],
                ),
              ),

              // Error message
              Obx(() {
                final msg = controller.errorMessage.value;
                if (msg == null) return const SizedBox(height: 0);
                return Padding(
                  padding: const EdgeInsets.only(top: AppSizes.space12),
                  child: Container(
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
                            msg,
                            style: TextStyle(
                              color: AppColors.onErrorContainer,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: controller.goToForgotPassword,
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.space16),

              // Sign in button
              Obx(() => DDPrimaryButton(
                    label: 'Sign In',
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.signInWithEmail,
                    isLoading: controller.isLoading.value,
                  )),

              const SizedBox(height: AppSizes.space24),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.outline)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
                    child: Text('or', style: TextStyle(color: AppColors.outline, fontSize: 13)),
                  ),
                  Expanded(child: Divider(color: AppColors.outline)),
                ],
              ),

              const SizedBox(height: AppSizes.space24),

              // Social sign in
              Obx(() => DDSecondaryButton(
                    label: 'Continue with Google',
                    icon: Icons.g_mobiledata,
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.signInWithGoogle,
                    isLoading: controller.isLoading.value,
                  )),

              const SizedBox(height: AppSizes.space16),

              DDSecondaryButton(
                label: 'Continue with Apple',
                icon: Icons.apple,
                isEnabled: false,
                onPressed: null,
              ),

              const SizedBox(height: AppSizes.space8),

              Text(
                'Coming soon',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.outline,
                ),
              ),

              const SizedBox(height: AppSizes.space32),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: controller.goToSignUp,
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.space8),

              // Terms
              Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.outline,
                ),
              ),

              const SizedBox(height: AppSizes.space32),
            ],
          ),
        ),
      ),
    );
  }
}
