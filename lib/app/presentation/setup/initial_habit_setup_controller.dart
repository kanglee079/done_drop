import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/activity.dart';
import '../../../core/models/activity_instance.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/local_cache_service.dart';
import '../../../core/utils/activity_utils.dart';
import '../../../app/routes/app_routes.dart';
import '../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../features/auth/repositories/user_profile_repository.dart';
import '../../../firebase/repositories/activity_repository.dart';
import '../../../l10n/l10n.dart';

class InitialHabitSetupController extends GetxController {
  InitialHabitSetupController(
    this._authController,
    this._activityRepository,
    this._userProfileRepository,
  );

  final AuthController _authController;
  final ActivityRepository _activityRepository;
  final UserProfileRepository _userProfileRepository;
  final _uuid = const Uuid();

  final RxBool isSaving = false.obs;
  final RxnString errorMessage = RxnString();
  late final List<TextEditingController> titleControllers;
  final RxList<TimeOfDay> reminderTimes = <TimeOfDay>[
    const TimeOfDay(hour: 8, minute: 0),
    const TimeOfDay(hour: 13, minute: 0),
    const TimeOfDay(hour: 20, minute: 0),
  ].obs;

  String? get _userId => _authController.firebaseUser?.uid;

  @override
  void onInit() {
    super.onInit();
    titleControllers = List.generate(3, (_) => TextEditingController());
    final l10n = currentL10n;
    titleControllers[0].text = l10n.setupMorningDefault;
    titleControllers[1].text = l10n.setupMiddayDefault;
    titleControllers[2].text = l10n.setupEveningDefault;
  }

  Future<void> pickReminderTime(BuildContext context, int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: reminderTimes[index],
    );
    if (picked == null) return;
    reminderTimes[index] = picked;
  }

  Future<void> completeSetup() async {
    if (isSaving.value) return;

    final trimmedTitles = titleControllers
        .map((controller) => controller.text.trim())
        .toList(growable: false);
    if (trimmedTitles.any((title) => title.length < 2)) {
      errorMessage.value = currentL10n.setupValidationError;
      return;
    }

    final uid = _userId;
    if (uid == null) return;

    isSaving.value = true;
    errorMessage.value = null;

    final now = DateTime.now();
    final activities = List.generate(trimmedTitles.length, (index) {
      final createdAt = now.add(Duration(milliseconds: index));
      return Activity(
        id: 'act_${_uuid.v4()}',
        ownerId: uid,
        title: trimmedTitles[index],
        recurrence: 'daily',
        reminderTime: formatReminderTimeValue(reminderTimes[index]),
        currentStreak: 0,
        longestStreak: 0,
        createdAt: createdAt,
        updatedAt: createdAt,
      );
    });

    final today = DateTime(now.year, now.month, now.day);
    final instances = activities
        .map(
          (activity) => ActivityInstance(
            id: 'inst_${activity.id}_${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
            activityId: activity.id,
            ownerId: uid,
            date: today,
            status: 'pending',
            createdAt: now,
            updatedAt: now,
          ),
        )
        .toList(growable: false);

    try {
      // Create activities with retry logic
      for (final activity in activities) {
        bool success = false;
        for (var attempt = 0; attempt < 3 && !success; attempt++) {
          try {
            await _activityRepository.createActivity(activity);
            success = true;
          } catch (e) {
            if (attempt == 2) rethrow;
            await Future.delayed(Duration(milliseconds: 300 * (attempt + 1)));
          }
        }
      }

      // Create instances with retry logic
      for (final instance in instances) {
        bool success = false;
        for (var attempt = 0; attempt < 3 && !success; attempt++) {
          try {
            await _activityRepository.getOrCreateTodayInstance(
              instance.activityId,
              uid,
            );
            success = true;
          } catch (e) {
            if (attempt == 2) rethrow;
            await Future.delayed(Duration(milliseconds: 300 * (attempt + 1)));
          }
        }
      }

      // Update user profile with retry logic
      UserProfile currentProfile;
      try {
        currentProfile = await _authController.ensureCurrentUserProfile() ??
            UserProfile(
              id: uid,
              displayName: _authController.firebaseUser?.displayName ?? '',
              createdAt: now,
            );
      } catch (_) {
        // If we can't read profile, create a minimal one
        currentProfile = UserProfile(
          id: uid,
          displayName: _authController.firebaseUser?.displayName ?? '',
          createdAt: now,
        );
      }

      final updatedProfile = currentProfile.copyWith(
        settings: currentProfile.settings.copyWith(
          hasCompletedHabitSetup: true,
        ),
      );

      bool profileUpdated = false;
      for (var attempt = 0; attempt < 3 && !profileUpdated; attempt++) {
        try {
          await _userProfileRepository.updateUserProfile(updatedProfile);
          profileUpdated = true;
        } catch (e) {
          if (attempt == 2) {
            // Non-critical: continue anyway
            debugPrint('Failed to update profile after 3 attempts: $e');
          }
          await Future.delayed(Duration(milliseconds: 300 * (attempt + 1)));
        }
      }

      // Cache activities locally
      final cachedActivities = LocalCacheService.instance
          .loadCachedActivities(uid)
          .map(Activity.fromFirestore);
      final mergedActivities = sortActivitiesBySchedule(<Activity>[
        ...cachedActivities,
        ...activities,
      ]);
      await LocalCacheService.instance.cacheActivities(
        uid,
        mergedActivities.map((activity) => activity.toFirestore()).toList(),
      );

      // Cache instances locally
      final cachedInstances = LocalCacheService.instance
          .loadCachedTodayInstances(uid)
          .map(ActivityInstance.fromFirestore)
          .toList();
      final mergedInstances = <ActivityInstance>[
        ...cachedInstances.where(
          (cached) => !instances.any(
            (created) => created.activityId == cached.activityId,
          ),
        ),
        ...instances,
      ];
      await LocalCacheService.instance.cacheTodayInstances(
        uid,
        mergedInstances.map((instance) => instance.toFirestore()).toList(),
      );

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      debugPrint('completeSetup error: $e');
      errorMessage.value = currentL10n.setupSaveError;
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    for (final controller in titleControllers) {
      controller.dispose();
    }
    super.onClose();
  }
}
