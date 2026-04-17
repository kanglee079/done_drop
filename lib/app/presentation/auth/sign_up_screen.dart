import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/features/auth/presentation/controllers/sign_up_controller.dart';
import 'package:done_drop/core/services/legal_service.dart';

class SignUpScreen extends GetView<SignUpController> {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spec = DDResponsiveSpec.of(context);

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
        child: DDResponsiveScrollBody(
          maxWidth: 520,
          padding: spec.pagePadding(
            top: AppSizes.space8,
            bottom: AppSizes.space24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                'Create Account',
                style: TextStyle(
                  fontFamily: AppTypography.serifFamily,
                  fontSize: spec.isCompact ? 34 : 36,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSizes.space8),
              Text(
                'Start capturing your done moments today.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSizes.space40),

              // Form
              Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    Obx(
                      () => DDTextField(
                        controller: controller.nameController,
                        label: 'Full Name',
                        hint: 'Your name',
                        prefixIcon: Icons.person_outline,
                        validator: controller.validateName,
                        textInputAction: TextInputAction.next,
                        enabled: !controller.isLoading.value,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space16),
                    Obx(
                      () => DDTextField(
                        controller: controller.emailController,
                        label: 'Email',
                        hint: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: controller.validateEmail,
                        textInputAction: TextInputAction.next,
                        enabled: !controller.isLoading.value,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space16),
                    Obx(
                      () => DDTextField(
                        controller: controller.passwordController,
                        label: 'Password',
                        hint: 'Min 6 characters',
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
                        textInputAction: TextInputAction.next,
                        enabled: !controller.isLoading.value,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space16),
                    Obx(
                      () => DDTextField(
                        controller: controller.confirmPasswordController,
                        label: 'Confirm Password',
                        hint: 'Repeat your password',
                        prefixIcon: Icons.lock_outlined,
                        obscureText: !controller.isConfirmPasswordVisible.value,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isConfirmPasswordVisible.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.onSurfaceVariant,
                            size: 20,
                          ),
                          onPressed: controller.toggleConfirmPasswordVisibility,
                        ),
                        validator: controller.validateConfirmPassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => controller.signUp(),
                        enabled: !controller.isLoading.value,
                      ),
                    ),
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
                        Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 18,
                        ),
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

              const SizedBox(height: AppSizes.space32),

              // Sign up button
              Obx(
                () => DDPrimaryButton(
                  label: 'Create Account',
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.signUp,
                  isLoading: controller.isLoading.value,
                ),
              ),

              const SizedBox(height: AppSizes.space24),

              // Sign in link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.goToSignIn,
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.space16),

              // Terms
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'By creating an account, you agree to our ',
                    style: TextStyle(fontSize: 11, color: AppColors.outline),
                  ),
                  TextButton(
                    onPressed: LegalService.instance.openTermsOfService,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Terms of Service'),
                  ),
                  Text(
                    ' and ',
                    style: TextStyle(fontSize: 11, color: AppColors.outline),
                  ),
                  TextButton(
                    onPressed: LegalService.instance.openPrivacyPolicy,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Privacy Policy'),
                  ),
                  Text(
                    '.',
                    style: TextStyle(fontSize: 11, color: AppColors.outline),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.space32),
            ],
          ),
        ),
      ),
    );
  }
}
