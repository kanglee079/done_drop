import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:done_drop/app/presentation/home/home_controller.dart';
import 'package:done_drop/app/presentation/home/widgets/habit_action_card.dart';
import 'package:done_drop/core/models/activity.dart';
import 'package:done_drop/core/models/activity_instance.dart';

Activity _makeActivity({String id = 'habit-1', String title = 'Read'}) =>
    Activity(
      id: id,
      ownerId: 'user-1',
      title: title,
      updatedAt: DateTime(2026, 4, 14),
    );

ActivityInstance _makeInstance({
  String id = 'inst-1',
  String activityId = 'habit-1',
  String status = 'pending',
  String? momentId,
}) =>
    ActivityInstance(
      id: id,
      activityId: activityId,
      ownerId: 'user-1',
      date: DateTime(2026, 4, 14),
      status: status,
      momentId: momentId,
      createdAt: DateTime(2026, 4, 14),
      updatedAt: DateTime(2026, 4, 14),
    );

void main() {
  group('HabitActionCard — hero variant', () {
    testWidgets('routes hero action through proof flow', (tester) async {
      var proofCompleteCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitActionCard(
              activity: _makeActivity(),
              instance: _makeInstance(),
              variant: HabitCardVariant.hero,
              actionState: HabitActionState.none,
              isCompleted: false,
              isOverdue: false,
              onCompleteWithProof: () async => proofCompleteCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('complete-proof-button')).last);
      await tester.pump();

      expect(proofCompleteCount, 1);
      expect(find.byKey(const Key('complete-now-button')), findsNothing);
    });

    testWidgets('shows only proof CTA while incomplete', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitActionCard(
              activity: _makeActivity(),
              instance: _makeInstance(),
              variant: HabitCardVariant.hero,
              actionState: HabitActionState.none,
              isCompleted: false,
              isOverdue: false,
              onCompleteWithProof: () async {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('complete-now-button')), findsNothing);
      expect(find.byKey(const Key('complete-proof-button')), findsOneWidget);
    });

    testWidgets('shows loading indicator on complete-with-proof actionState', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitActionCard(
              activity: _makeActivity(),
              instance: _makeInstance(),
              variant: HabitCardVariant.hero,
              actionState: HabitActionState.completeWithProof,
              isCompleted: false,
              isOverdue: false,
              onCompleteWithProof: () async {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsWidgets);
      expect(find.byKey(const Key('complete-proof-button')), findsOneWidget);
    });

    testWidgets('shows completed state instead of buttons when isCompleted=true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitActionCard(
              activity: _makeActivity(),
              instance: _makeInstance(),
              variant: HabitCardVariant.hero,
              actionState: HabitActionState.none,
              isCompleted: true,
              isOverdue: false,
              onCompleteWithProof: () async {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('complete-now-button')), findsNothing);
      expect(find.byKey(const Key('complete-proof-button')), findsNothing);
      expect(find.text('Completed today'), findsOneWidget);
    });
  });

  group('HabitActionCard — content variant', () {
    testWidgets('triggers quick complete on pill tap', (tester) async {
      var completeCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitActionCard(
              activity: _makeActivity(),
              instance: _makeInstance(),
              variant: HabitCardVariant.content,
              actionState: HabitActionState.none,
              isCompleted: false,
              isOverdue: false,
              onCompleteWithProof: () async => completeCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('list-complete-pill')).last);
      await tester.pump();

      expect(completeCount, 1);
    });

    testWidgets('shows loading indicator on pill during quick-complete', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitActionCard(
              activity: _makeActivity(),
              instance: _makeInstance(),
              variant: HabitCardVariant.content,
              actionState: HabitActionState.quickComplete,
              isCompleted: false,
              isOverdue: false,
              onCompleteWithProof: () async {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('list-complete-pill')), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('shows loading indicator on proof button during complete-with-proof', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitActionCard(
              activity: _makeActivity(),
              instance: _makeInstance(),
              variant: HabitCardVariant.content,
              actionState: HabitActionState.completeWithProof,
              isCompleted: false,
              isOverdue: false,
              onCompleteWithProof: () async {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('list-proof-button')), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('hides proof button when isCompleted=true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitActionCard(
              activity: _makeActivity(),
              instance: _makeInstance(),
              variant: HabitCardVariant.content,
              actionState: HabitActionState.none,
              isCompleted: true,
              isOverdue: false,
              onCompleteWithProof: () async {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('list-proof-button')), findsNothing);
    });

    testWidgets('shows verified icon when hasProof=true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitActionCard(
              activity: _makeActivity(),
              instance: _makeInstance(momentId: 'moment-1'),
              variant: HabitCardVariant.content,
              actionState: HabitActionState.none,
              isCompleted: true,
              isOverdue: false,
              onCompleteWithProof: () async {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
    });

    testWidgets('disabled pill does not call proof flow when isCompleted=true', (tester) async {
      var tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitActionCard(
              activity: _makeActivity(),
              instance: _makeInstance(),
              variant: HabitCardVariant.content,
              actionState: HabitActionState.none,
              isCompleted: true,
              isOverdue: false,
              onCompleteWithProof: () async => tapCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('list-complete-pill')).last);
      await tester.pump();

      expect(tapCount, 0);
    });
  });
}
