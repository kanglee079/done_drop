import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:done_drop/app/presentation/friends/friends_controller.dart';
import 'package:done_drop/app/presentation/friends/friends_screen.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/l10n/app_localizations.dart';

class _FakeFirestore implements FirebaseFirestore {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestFriendsController extends FriendsController {
  _TestFriendsController() : super(FriendRepository(_FakeFirestore()));

  @override
  // ignore: must_call_super
  void onInit() {}
}

Future<void> _pumpFriendsRoute(
  WidgetTester tester,
  FriendsController controller, {
  Map<String, dynamic>? arguments,
}) async {
  Get.put<FriendsController>(controller);

  await tester.pumpWidget(
    GetMaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SizedBox.shrink(),
      getPages: [
        GetPage(name: '/friends', page: () => const FriendsScreen()),
      ],
    ),
  );

  Get.toNamed('/friends', arguments: arguments);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('FriendsScreen', () {
    testWidgets('opens requests tab when requested from route arguments', (
      tester,
    ) async {
      final controller = _TestFriendsController();

      await _pumpFriendsRoute(
        tester,
        controller,
        arguments: {'initialTab': 'requests'},
      );

      expect(find.text('No pending requests'), findsOneWidget);
      expect(
        find.text('Incoming and outgoing requests appear here.'),
        findsOneWidget,
      );
      expect(find.text('No friends yet'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
