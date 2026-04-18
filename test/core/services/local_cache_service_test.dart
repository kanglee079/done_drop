import 'package:flutter_test/flutter_test.dart';

import 'package:done_drop/core/services/local_cache_service.dart';

void main() {
  group('LocalCacheService keys', () {
    test('activities cache key is scoped per user', () {
      expect(
        LocalCacheService.activitiesKeyForUser('user_a'),
        isNot(LocalCacheService.activitiesKeyForUser('user_b')),
      );
    });

    test('today instances cache key is scoped per user and day', () {
      final day = DateTime(2026, 4, 18);

      expect(
        LocalCacheService.todayKeyForUser('user_a', now: day),
        isNot(LocalCacheService.todayKeyForUser('user_b', now: day)),
      );
      expect(
        LocalCacheService.todayKeyForUser('user_a', now: day),
        isNot(
          LocalCacheService.todayKeyForUser(
            'user_a',
            now: day.add(const Duration(days: 1)),
          ),
        ),
      );
    });
  });
}
