class AppLinks {
  AppLinks._();

  /// Set these to deployed public URLs before store submission.
  /// The app falls back to in-app legal screens until the web pages are live.
  static const String privacyPolicyUrl =
      'https://donedrop-1d764.web.app/legal/privacy.html';
  static const String termsOfServiceUrl =
      'https://donedrop-1d764.web.app/legal/terms.html';

  static bool get hasPublicPrivacyPolicy =>
      privacyPolicyUrl.startsWith('https://');
  static bool get hasPublicTerms => termsOfServiceUrl.startsWith('https://');
}
