import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:done_drop/core/theme/app_typography.dart';
import 'package:done_drop/core/constants/app_constants.dart';

void main() {
  group('AppTypography', () {
    test('serifFamily returns "Newsreader"', () {
      expect(AppTypography.serifFamily, 'Newsreader');
    });

    test('sansFamily returns "Manrope"', () {
      expect(AppTypography.sansFamily, 'Manrope');
    });

    test('displayLarge returns non-null TextStyle with correct font', () {
      final style = AppTypography.displayLarge();
      expect(style.fontFamily, 'Newsreader');
      expect(style.fontWeight, FontWeight.w700);
      expect(style.fontSize, 56);
    });

    test('bodyMedium returns non-null TextStyle with sans font', () {
      final style = AppTypography.bodyMedium();
      expect(style.fontFamily, 'Manrope');
      expect(style.fontWeight, FontWeight.w400);
      expect(style.fontSize, 14);
    });

    test('quote returns italic serif', () {
      final style = AppTypography.quote();
      expect(style.fontFamily, 'Newsreader');
      expect(style.fontStyle, FontStyle.italic);
    });

    test('headlineMedium with color override', () {
      final style = AppTypography.headlineMedium(color: Colors.red);
      expect(style.color, Colors.red);
      expect(style.fontSize, 28);
    });
  });

  group('AppConstants', () {
    test('visibility constants are defined', () {
      expect(AppConstants.visibilityPersonalOnly, 'personal_only');
      expect(AppConstants.visibilityAllFriends, 'all_friends');
      expect(AppConstants.visibilitySelectedFriends, 'selected_friends');
    });

    test('recurrence types are defined', () {
      expect(AppConstants.recurrenceDaily, 'daily');
      expect(AppConstants.recurrenceWeekly, 'weekly');
      expect(AppConstants.recurrenceMonthly, 'monthly');
      expect(AppConstants.recurrenceNone, 'none');
    });

    test('instance status constants are defined', () {
      expect(AppConstants.instanceStatusPending, 'pending');
      expect(AppConstants.instanceStatusCompleted, 'completed');
      expect(AppConstants.instanceStatusMissed, 'missed');
    });

    test('friend request status constants are defined', () {
      expect(AppConstants.friendStatusPending, 'pending');
      expect(AppConstants.friendStatusAccepted, 'accepted');
      expect(AppConstants.friendStatusDeclined, 'declined');
      expect(AppConstants.friendStatusCancelled, 'cancelled');
    });

    test('friend cap for free tier is 5', () {
      expect(AppConstants.maxFriendsFree, 5);
    });

    test('maxCaptionLength is 300', () {
      expect(AppConstants.maxCaptionLength, 300);
    });

    test('moment categories are discipline-focused', () {
      // Categories should NOT include "Reflections" (diary mindset)
      expect(AppConstants.momentCategories.contains('Reflections'), false);
      expect(AppConstants.momentCategories.isNotEmpty, true);
    });

    test('onboarding use cases are discipline-first (2 options only)', () {
      expect(AppConstants.onboardingUseCases.length, 2);
      expect(AppConstants.onboardingUseCases[0]['key'], 'personal');
      expect(AppConstants.onboardingUseCases[1]['key'], 'with_friends');
    });

    test('reaction types are positive reinforcement', () {
      expect(AppConstants.reactionTypes, ['love', 'celebrate', 'inspiring']);
    });

    test('animation durations are defined', () {
      expect(AppConstants.animFast.inMilliseconds, 200);
      expect(AppConstants.animMedium.inMilliseconds, 350);
      expect(AppConstants.animSlow.inMilliseconds, 600);
    });

    test('app info constants', () {
      expect(AppConstants.appName, 'DoneDrop');
      expect(AppConstants.appVersion, '1.0.0');
    });
  });
}
