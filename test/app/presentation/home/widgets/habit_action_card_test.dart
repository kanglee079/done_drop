import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:done_drop/app/presentation/home/home_controller.dart';
import 'package:done_drop/app/presentation/home/widgets/habit_action_card.dart';
import 'package:done_drop/core/models/activity.dart';
import 'package:done_drop/core/models/activity_instance.dart';

void main() {
  testWidgets('hero habit card triggers both complete actions', (tester) async {
    var quickCompleteCount = 0;
    var proofCompleteCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HabitActionCard(
            activity: Activity(
              id: 'habit-1',
              ownerId: 'user-1',
              title: 'Read',
              updatedAt: DateTime(2026, 4, 14),
            ),
            instance: ActivityInstance(
              id: 'inst-1',
              activityId: 'habit-1',
              ownerId: 'user-1',
              date: DateTime(2026, 4, 14),
              status: 'pending',
              createdAt: DateTime(2026, 4, 14),
              updatedAt: DateTime(2026, 4, 14),
            ),
            variant: HabitCardVariant.hero,
            actionState: HabitActionState.none,
            isCompleted: false,
            isOverdue: false,
            onCompleteNow: () async => quickCompleteCount++,
            onCompleteWithProof: () async => proofCompleteCount++,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('complete-now-button')).last);
    await tester.pump();
    await tester.tap(find.byKey(const Key('complete-proof-button')).last);
    await tester.pump();

    expect(quickCompleteCount, 1);
    expect(proofCompleteCount, 1);
  });
}
