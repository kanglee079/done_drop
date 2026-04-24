import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/features/auth/presentation/controllers/sign_in_controller.dart';
import 'package:done_drop/core/services/legal_service.dart';
import 'package:done_drop/core/services/locale_controller.dart';
import 'package:done_drop/l10n/l10n.dart';

class SignInScreen extends GetView<SignInController> {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spec = DDResponsiveSpec.of(context);
    final l10n = context.l10n;
    final showGoogleSignIn = controller.shouldOfferGoogleSignIn;
    final googleNotice = controller.googleSignInAvailabilityNotice;
    final localeController = Get.isRegistered<LocaleController>()
        ? Get.find<LocaleController>()
        : null;

    return DismissKeyboard(
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Stack(
            children: [
              DDResponsiveScrollBody(
                maxWidth: 520,
                padding: spec.pagePadding(
                  top: spec.isShort ? AppSizes.space24 : AppSizes.space40,
                  bottom: AppSizes.space24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (localeController != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: PopupMenuButton<String>(
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
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.space12,
                              vertical: AppSizes.space8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: AppSizes.borderRadiusFull,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.language_rounded, size: 18),
                                const SizedBox(width: AppSizes.space8),
                                Text(
                                  localeController.isVietnamese
                                      ? l10n.languageVietnamese
                                      : l10n.languageEnglish,
                                  style: AppTypography.labelMedium(
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: spec.isShort ? 0 : AppSizes.space24),
                    Center(
                      child: Text(
                        l10n.appName,
                        style: TextStyle(
                          fontFamily: AppTypography.serifFamily,
                          fontSize: spec.isCompact ? 44 : 48,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.space8),
                    Center(
                      child: Text(
                        l10n.authTagline,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: spec.isShort
                          ? AppSizes.space32
                          : AppSizes.space48,
                    ),
                    Form(
                      key: controller.formKey,
                      child: Column(
                        children: [
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
                              enabled: !controller.isBusy,
                            ),
                          ),
                          const SizedBox(height: AppSizes.space16),
                          Obx(
                            () => DDTextField(
                              controller: controller.passwordController,
                              label: l10n.passwordLabel,
                              hint: l10n.passwordHint,
                              prefixIcon: Icons.lock_outlined,
                              autofillHints: const [AutofillHints.password],
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
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) =>
                                  controller.signInWithEmail(),
                              enabled: !controller.isBusy,
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: controller.isBusy
                            ? null
                            : controller.goToForgotPassword,
                        child: Text(
                          l10n.forgotPasswordAction,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.space16),
                    Obx(
                      () => DDPrimaryButton(
                        label: l10n.signInAction,
                        onPressed: controller.isBusy
                            ? null
                            : controller.signInWithEmail,
                        isLoading: controller.isEmailLoading.value,
                      ),
                    ),
                    if (!showGoogleSignIn && googleNotice != null) ...[
                      const SizedBox(height: AppSizes.space16),
                      _AuthInfoBanner(message: googleNotice),
                    ],
                    if (showGoogleSignIn) ...[
                      const SizedBox(height: AppSizes.space24),
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.outline)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.space16,
                            ),
                            child: Text(
                              l10n.orLabel,
                              style: TextStyle(
                                color: AppColors.outline,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.outline)),
                        ],
                      ),
                      const SizedBox(height: AppSizes.space24),
                      Obx(
                        () => DDSecondaryButton(
                          label: l10n.continueWithGoogle,
                          icon: Icons.g_mobiledata,
                          onPressed: controller.isBusy
                              ? null
                              : controller.signInWithGoogle,
                          isLoading: controller.isGoogleLoading.value,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSizes.space32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.noAccountPrompt,
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.isBusy
                              ? null
                              : controller.goToSignUp,
                          child: Text(
                            l10n.signUpAction,
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
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          l10n.termsAgreementPrefix,
                          textAlign: TextAlign.center,
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
                if (!controller.isBusy) return const SizedBox.shrink();
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

class _AuthInfoBanner extends StatelessWidget {
  const _AuthInfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.space12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppSizes.borderRadiusMd,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: AppSizes.space8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
