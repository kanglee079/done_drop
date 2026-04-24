import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/presentation/friends/add_friend_controller.dart';
import 'package:done_drop/app/presentation/friends/add_friend_screen.dart';
import 'package:done_drop/core/models/user_profile.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/l10n/app_localizations.dart';

class _FakeFirestore implements FirebaseFirestore {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestAddFriendController extends AddFriendController {
  _TestAddFriendController() : super(FriendRepository(_FakeFirestore()));

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  // ignore: must_call_super
  void onReady() {}
}

Future<void> _pumpAddFriendScreen(
  WidgetTester tester,
  _TestAddFriendController controller,
) async {
  Get.put<AddFriendController>(controller);

  await tester.pumpWidget(
    GetMaterialApp(
      home: const AddFriendScreen(),
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    ),
  );
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('AddFriendScreen', () {
    testWidgets(
      'renders error and found-user feedback together without widget exceptions',
      (tester) async {
        final controller = _TestAddFriendController();
        controller.foundUser.value = UserProfile(
          id: 'buddy-1',
          displayName: 'Codex Buddy',
          createdAt: DateTime(2024, 4, 21),
        );
        controller.errorMessage.value = 'Friend request already exists';

        await _pumpAddFriendScreen(tester, controller);

        expect(find.text('Codex Buddy'), findsOneWidget);
        expect(find.text('Friend request already exists'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('survives sending state without widget exceptions', (
      tester,
    ) async {
      final controller = _TestAddFriendController();
      controller.foundUser.value = UserProfile(
        id: 'buddy-1',
        displayName: 'Codex Buddy',
        createdAt: DateTime(2024, 4, 21),
      );

      await _pumpAddFriendScreen(tester, controller);
      controller.isSendingRequest.value = true;
      await tester.pump();

      expect(find.text('Codex Buddy'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(DDPrimaryButton), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
