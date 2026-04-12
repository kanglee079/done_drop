import 'package:firebase_analytics/firebase_analytics.dart';

/// DoneDrop Analytics Service
/// Tracks meaningful events for product insights
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? _analytics;

  void init(FirebaseAnalytics analytics) {
    _analytics = analytics;
  }

  FirebaseAnalytics? get _a => _analytics;

  // ── Onboarding ────────────────────────────────────────────────────────────
  Future<void> onboardingStarted() async {
    await _a?.logEvent(name: 'onboarding_started');
  }

  Future<void> onboardingCompleted() async {
    await _a?.logEvent(name: 'onboarding_completed');
  }

  Future<void> useCaseSelected(String useCase) async {
    await _a?.logEvent(
      name: 'use_case_selected',
      parameters: {'use_case': useCase},
    );
  }

  // ── Auth ──────────────────────────────────────────────────────────────────
  Future<void> signInStarted() async {
    await _a?.logEvent(name: 'sign_in_started');
  }

  Future<void> signInCompleted() async {
    await _a?.logEvent(name: 'sign_in_completed');
  }

  Future<void> signInFailed(String reason) async {
    await _a?.logEvent(
      name: 'sign_in_failed',
      parameters: {'reason': reason},
    );
  }

  Future<void> logLogin(String method) async {
    await _a?.logEvent(
      name: 'login',
      parameters: {'method': method},
    );
  }

  Future<void> signOut() async {
    await _a?.logEvent(name: 'user_signed_out');
  }

  Future<void> passwordResetRequested() async {
    await _a?.logEvent(name: 'password_reset_requested');
  }

  // ── Task & Moment Creation ──────────────────────────────────────────────
  Future<void> taskCreated() async {
    await _a?.logEvent(name: 'task_created');
  }

  Future<void> taskArchived() async {
    await _a?.logEvent(name: 'task_archived');
  }

  Future<void> momentDoneTapped() async {
    await _a?.logEvent(name: 'moment_done_tapped');
  }

  Future<void> photoCaptureStarted() async {
    await _a?.logEvent(name: 'photo_capture_started');
  }

  Future<void> photoSelected(String source) async {
    await _a?.logEvent(
      name: 'photo_selected',
      parameters: {'source': source}, // camera, gallery
    );
  }

  Future<void> momentPosted({
    required String visibility,
    String? circleId,
    String? category,
  }) async {
    await _a?.logEvent(
      name: 'moment_posted',
      parameters: {
        'visibility': visibility,
        'circle_id': circleId ?? '',
        'category': category ?? '',
      },
    );
  }

  Future<void> momentDeleted() async {
    await _a?.logEvent(name: 'moment_deleted');
  }

  // ── Circles ──────────────────────────────────────────────────────────────
  Future<void> circleCreated() async {
    await _a?.logEvent(name: 'circle_created');
  }

  Future<void> circleJoined(String circleId) async {
    await _a?.logEvent(
      name: 'circle_joined',
      parameters: {'circle_id': circleId},
    );
  }

  Future<void> circleLeft(String circleId) async {
    await _a?.logEvent(
      name: 'circle_left',
      parameters: {'circle_id': circleId},
    );
  }

  Future<void> inviteSent() async {
    await _a?.logEvent(name: 'invite_sent');
  }

  Future<void> inviteAccepted() async {
    await _a?.logEvent(name: 'invite_accepted');
  }

  // ── Reactions ────────────────────────────────────────────────────────────
  Future<void> reactionSent(String momentId, String reactionType) async {
    await _a?.logEvent(
      name: 'reaction_sent',
      parameters: {
        'moment_id': momentId,
        'reaction_type': reactionType,
      },
    );
  }

  Future<void> reactionRemoved(String momentId) async {
    await _a?.logEvent(
      name: 'reaction_removed',
      parameters: {'moment_id': momentId},
    );
  }

  // ── Recap ────────────────────────────────────────────────────────────────
  Future<void> recapViewed(String weekKey) async {
    await _a?.logEvent(
      name: 'recap_viewed',
      parameters: {'week_key': weekKey},
    );
  }

  Future<void> recapShared() async {
    await _a?.logEvent(name: 'recap_shared');
  }

  // ── Premium ──────────────────────────────────────────────────────────────
  Future<void> paywallViewed(String entryPoint) async {
    await _a?.logEvent(
      name: 'paywall_viewed',
      parameters: {'entry_point': entryPoint},
    );
  }

  Future<void> purchaseStarted() async {
    await _a?.logEvent(name: 'purchase_started');
  }

  Future<void> purchaseCompleted() async {
    await _a?.logEvent(name: 'purchase_completed');
  }

  Future<void> purchaseFailed(String reason) async {
    await _a?.logEvent(
      name: 'purchase_failed',
      parameters: {'reason': reason},
    );
  }

  Future<void> restoreCompleted(bool success) async {
    await _a?.logEvent(
      name: 'restore_completed',
      parameters: {'success': success.toString()},
    );
  }

  // ── Moderation ───────────────────────────────────────────────────────────
  Future<void> reportSubmitted() async {
    await _a?.logEvent(name: 'report_submitted');
  }

  Future<void> blockUser(String userId) async {
    await _a?.logEvent(
      name: 'block_user',
      parameters: {'blocked_user_id': userId},
    );
  }

  // ── Settings ─────────────────────────────────────────────────────────────
  Future<void> settingChanged(String key, dynamic value) async {
    await _a?.logEvent(
      name: 'setting_changed',
      parameters: {'key': key, 'value': value.toString()},
    );
  }
}
