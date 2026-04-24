import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/features/auth/presentation/controllers/sign_up_controller.dart';
import 'package:done_drop/core/services/legal_service.dart';
import 'package:done_drop/core/services/locale_controller.dart';
import 'package:done_drop/l10n/l10n.dart';

class SignUpScreen extends GetView<SignUpController> {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spec = DDResponsiveSpec.of(context);
    final l10n = context.l10n;
    final localeController = Get.isRegistered<LocaleController>()
        ? Get.find<LocaleController>()
        : null;

    return DismissKeyboard(
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () => Get.back(),
          ),
          actions: localeController == null
              ? null
              : [
                  PopupMenuButton<String>(
                    initialValue: localeController.currentLanguageCode,
                    onSelected: localeController.setLocaleCode,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'en',
                        child: Text(l10n.languageEnglish),
                      ),
                      PopupMenuItem(
                        value: 'vi',
                        child: Text(l10n.languageVietnamese),
                      ),
                    ],
                    icon: const Icon(
                      Icons.language_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              DDResponsiveScrollBody(
                maxWidth: 520,
                padding: spec.pagePadding(
                  top: AppSizes.space8,
                  bottom: AppSizes.space24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.createAccountTitle,
                      style: TextStyle(
                        fontFamily: AppTypography.serifFamily,
                        fontSize: spec.isCompact ? 34 : 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space8),
                    Text(
                      l10n.createAccountSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space40),
                    Form(
                      key: controller.formKey,
                      child: Column(
                        children: [
                          Obx(
                            () => DDTextField(
                              controller: controller.nameController,
                              label: l10n.fullNameLabel,
                              hint: l10n.fullNameHint,
                              prefixIcon: Icons.person_outline,
                              autofillHints: const [AutofillHints.name],
                              validator: controller.validateName,
                              onChanged: (_) =>
                                  controller.clearInlineMessages(),
                              textInputAction: TextInputAction.next,
                              enabled: !controller.isLoading.value,
                            ),
                          ),
                          const SizedBox(height: AppSizes.space16),
                          Obx(
                            () => DDTextField(
                              controller: controller.emailController,
                              label: l10n.emailLabel,
                              hint: l10n.emailHint,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [
                                AutofillHints.email,
                                AutofillHints.username,
                              ],
                              autocorrect: false,
                              enableSuggestions: false,
                              prefixIcon: Icons.email_outlined,
                              validator: controller.validateEmail,
                              onChanged: (_) =>
                                  controller.clearInlineMessages(),
                              textInputAction: TextInputAction.next,
                              enabled: !controller.isLoading.value,
                            ),
                          ),
                          const SizedBox(height: AppSizes.space16),
                          Obx(
                            () => DDTextField(
                              controller: controller.passwordController,
                              label: l10n.passwordLabel,
                              hint: l10n.passwordHint,
                              prefixIcon: Icons.lock_outlined,
                              autofillHints: const [AutofillHints.newPassword],
                              autocorrect: false,
                              enableSuggestions: false,
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
                              onChanged: (_) =>
                                  controller.clearInlineMessages(),
                              textInputAction: TextInputAction.next,
                              enabled: !controller.isLoading.value,
                            ),
                          ),
                          const SizedBox(height: AppSizes.space16),
                          Obx(
                            () => DDTextField(
                              controller: controller.confirmPasswordController,
                              label: l10n.confirmPasswordLabel,
                              hint: l10n.confirmPasswordHint,
                              prefixIcon: Icons.lock_outlined,
                              autofillHints: const [AutofillHints.newPassword],
                              autocorrect: false,
                              enableSuggestions: false,
                              obscureText:
                                  !controller.isConfirmPasswordVisible.value,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isConfirmPasswordVisible.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.onSurfaceVariant,
                                  size: 20,
                                ),
                                onPressed:
                                    controller.toggleConfirmPasswordVisibility,
                              ),
                              validator: controller.validateConfirmPassword,
                              onChanged: (_) =>
                                  controller.clearInlineMessages(),
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => controller.signUp(),
                              enabled: !controller.isLoading.value,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                    Obx(
                      () => DDPrimaryButton(
                        label: l10n.createAccountAction,
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.signUp,
                        isLoading: controller.isLoading.value,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.alreadyHaveAccountPrompt,
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.goToSignIn,
                          child: Text(
                            l10n.signInAction,
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
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          l10n.createTermsAgreementPrefix,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.outline,
                          ),
                        ),
                        TextButton(
                          onPressed: LegalService.instance.openTermsOfService,
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(l10n.termsOfService),
                        ),
                        Text(
                          l10n.andLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.outline,
                          ),
                        ),
                        TextButton(
                          onPressed: LegalService.instance.openPrivacyPolicy,
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(l10n.privacyPolicy),
                        ),
                        Text(
                          '.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.space32),
                  ],
                ),
              ),
              Obx(() {
                if (!controller.isLoading.value) {
                  return const SizedBox.shrink();
                }
                return _AuthProgressOverlay(
                  message:
                      controller.statusMessage.value ??
                      l10n.authPreparingAppStatus,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthProgressOverlay extends StatelessWidget {
  const _AuthProgressOverlay({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: Container(
          color: AppColors.surface.withValues(alpha: 0.88),
          alignment: Alignment.center,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 280),
            margin: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
            padding: const EdgeInsets.all(AppSizes.space20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: AppSizes.borderRadiusLg,
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSizes.space16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium(color: AppColors.onSurface),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
