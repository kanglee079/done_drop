class AppLinks {
  AppLinks._();

  /// Set these to deployed public URLs before store submission.
  /// The app falls back to in-app legal screens until the web pages are live.
  static const String privacyPolicyUrl = '';
  static const String termsOfServiceUrl = '';

  static bool get hasPublicPrivacyPolicy =>
      privacyPolicyUrl.startsWith('https://');
  static bool get hasPublicTerms => termsOfServiceUrl.startsWith('https://');
}
