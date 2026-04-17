import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/models/activity.dart';
import 'package:done_drop/core/models/activity_instance.dart';
import 'package:done_drop/core/models/completion_log.dart';
import 'package:done_drop/core/services/activity_completion_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CompleteHabitUseCase', () {
    late FakeCompletionRepository repository;
    late FakeConnectivity connectivity;
    late FakeCompletionQueue queue;
    late bool cacheInvalidated;
    late int hapticCount;

    setUp(() {
      repository = FakeCompletionRepository();
      connectivity = FakeConnectivity(true);
      queue = FakeCompletionQueue();
      cacheInvalidated = false;
      hapticCount = 0;
    });

    test(
      'already-completed instance returns null without side-effects',
      () async {
        repository.instance = repository.instance.copyWith(status: 'completed');

        final useCase = CompleteHabitUseCase(
          activityRepository: repository,
          connectivity: connectivity,
          offlineQueue: queue,
          invalidateTodayInstances: () async => cacheInvalidated = true,
          onCompletionHaptic: () async => hapticCount++,
        );

        final result = await useCase(activityId: 'habit-1', userId: 'user-1');

        expect(result, isNull);
        expect(repository.completedInstanceIds, isEmpty);
        expect(repository.createdLogs, isEmpty);
        expect(queue.calls, isEmpty);
        expect(cacheInvalidated, isFalse);
        expect(hapticCount, 0);
      },
    );

    test(
      'completes online through a single pipeline and updates bound state',
      () async {
        repository.instance = repository.instance.copyWith(status: 'pending');

        final useCase = CompleteHabitUseCase(
          activityRepository: repository,
          connectivity: connectivity,
          offlineQueue: queue,
          invalidateTodayInstances: () async => cacheInvalidated = true,
          onCompletionHaptic: () async => hapticCount++,
        );

        final todayInstances = <String, ActivityInstance>{}.obs;
        final activities = <Activity>[
          Activity(
            id: 'habit-1',
            ownerId: 'user-1',
            title: 'Read',
            currentStreak: 3,
            longestStreak: 4,
            updatedAt: DateTime(2026),
          ),
        ].obs;

        useCase.bindReactiveState(
          todayInstances: todayInstances,
          activities: activities,
        );

        final result = await useCase(activityId: 'habit-1', userId: 'user-1');

        expect(result, isNotNull);
        expect(repository.completedInstanceIds, ['inst-1']);
        expect(repository.createdLogs, hasLength(1));
        expect(repository.incrementedActivityIds, ['habit-1']);
        expect(queue.calls, isEmpty);
        expect(cacheInvalidated, isTrue);
        expect(hapticCount, 1);
        expect(todayInstances['habit-1']?.isCompleted, isTrue);
        expect(activities.single.currentStreak, 4);
        expect(activities.single.longestStreak, 4);
      },
    );

    test('queues offline completion with exact instance context', () async {
      repository.instance = repository.instance.copyWith(status: 'pending');
      connectivity = FakeConnectivity(false);

      final useCase = CompleteHabitUseCase(
        activityRepository: repository,
        connectivity: connectivity,
        offlineQueue: queue,
        invalidateTodayInstances: () async => cacheInvalidated = true,
        onCompletionHaptic: () async => hapticCount++,
      );

      final todayInstances = <String, ActivityInstance>{}.obs;
      final activities = <Activity>[
        Activity(
          id: 'habit-1',
          ownerId: 'user-1',
          title: 'Read',
          currentStreak: 1,
          longestStreak: 2,
          updatedAt: DateTime(2026),
        ),
      ].obs;

      useCase.bindReactiveState(
        todayInstances: todayInstances,
        activities: activities,
      );

      final result = await useCase(activityId: 'habit-1', userId: 'user-1');

      expect(result, isNotNull);
      expect(repository.completedInstanceIds, isEmpty);
      expect(repository.createdLogs, isEmpty);
      expect(repository.incrementedActivityIds, isEmpty);
      expect(queue.calls, hasLength(1));
      expect(queue.calls.single.instanceId, 'inst-1');
      expect(queue.calls.single.activityId, 'habit-1');
      expect(queue.calls.single.ownerId, 'user-1');
      expect(cacheInvalidated, isFalse);
      expect(hapticCount, 1);
      expect(todayInstances['habit-1']?.isCompleted, isTrue);
      expect(activities.single.currentStreak, 2);
      expect(result?.wasOffline, isTrue);
    });
  });
}

class FakeCompletionRepository implements HabitCompletionRepository {
  ActivityInstance instance;
  FakeCompletionRepository() : instance = _makePendingInstance();

  static ActivityInstance _makePendingInstance() => ActivityInstance(
    id: 'inst-1',
    activityId: 'habit-1',
    ownerId: 'user-1',
    date: DateTime(2026, 4, 14),
    status: 'pending',
    createdAt: DateTime(2026, 4, 14),
    updatedAt: DateTime(2026, 4, 14),
  );

  final List<String> completedInstanceIds = <String>[];
  final List<CompletionLog> createdLogs = <CompletionLog>[];
  final List<String> incrementedActivityIds = <String>[];

  @override
  Future<void> completeInstance(String instanceId, {String? momentId}) async {
    completedInstanceIds.add(instanceId);
  }

  @override
  Future<void> createCompletionLog(CompletionLog log) async {
    createdLogs.add(log);
  }

  @override
  Future<ActivityInstance> getOrCreateTodayInstance(
    String activityId,
    String ownerId,
  ) async {
    return instance;
  }

  @override
  Future<void> incrementStreak(String activityId) async {
    incrementedActivityIds.add(activityId);
  }
}

class FakeConnectivity implements ConnectivityStatusReader {
  FakeConnectivity(this.isOnlineNow);

  @override
  final bool isOnlineNow;
}

class FakeCompletionQueue implements HabitCompletionQueue {
  final List<QueuedCompletionCall> calls = <QueuedCompletionCall>[];

  @override
  Future<void> queueCompleteHabit({
    required String activityId,
    required String instanceId,
    required String ownerId,
    required String completionLogId,
    required DateTime completedAt,
  }) async {
    calls.add(
      QueuedCompletionCall(
        activityId: activityId,
        instanceId: instanceId,
        ownerId: ownerId,
        completionLogId: completionLogId,
        completedAt: completedAt,
      ),
    );
  }
}

class QueuedCompletionCall {
  const QueuedCompletionCall({
    required this.activityId,
    required this.instanceId,
    required this.ownerId,
    required this.completionLogId,
    required this.completedAt,
  });

  final String activityId;
  final String instanceId;
  final String ownerId;
  final String completionLogId;
  final DateTime completedAt;
}
