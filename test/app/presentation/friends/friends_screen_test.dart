import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:done_drop/core/models/friend_request.dart';
import 'package:done_drop/core/models/user_profile.dart';
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

class _BusyAcceptFriendsController extends _TestFriendsController {
  final RxSet<String> _acceptingIds = <String>{}.obs;
  final Completer<bool> _acceptCompleter = Completer<bool>();
  int acceptCallCount = 0;

  void completeAccept([bool value = true]) {
    if (!_acceptCompleter.isCompleted) {
      _acceptCompleter.complete(value);
    }
  }

  @override
  bool isRequestBusy(String requestId) => _acceptingIds.contains(requestId);

  @override
  bool isAccepting(String requestId) => _acceptingIds.contains(requestId);

  @override
  bool isDeclining(String requestId) => false;

  @override
  bool isCancelling(String requestId) => false;

  @override
  Future<UserProfile?> requestProfileFutureFor(String userId) async {
    return UserProfile(
      id: userId,
      displayName: 'Buddy Tester',
      userCode: 'BDY123',
      createdAt: DateTime(2026, 1, 1),
    );
  }

  @override
  Future<bool> acceptRequest(FriendRequest request) async {
    acceptCallCount += 1;
    if (_acceptingIds.contains(request.id)) {
      return false;
    }
    _acceptingIds.add(request.id);
    try {
      return await _acceptCompleter.future;
    } finally {
      _acceptingIds.remove(request.id);
    }
  }
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
      getPages: [GetPage(name: '/friends', page: () => const FriendsScreen())],
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

    testWidgets(
      'shows accepting loading state immediately when accepting an incoming request',
      (tester) async {
        final controller = _BusyAcceptFriendsController();
        controller.incomingRequests.assignAll([
          FriendRequest(
            id: 'req-1',
            senderId: 'sender-1',
            receiverId: 'receiver-1',
            status: 'pending',
            createdAt: DateTime(2026, 1, 1),
            senderDisplayName: 'Buddy Tester',
          ),
        ]);
        controller.pendingRequestCount.value = 1;

        await _pumpFriendsRoute(
          tester,
          controller,
          arguments: {'initialTab': 'requests'},
        );

        expect(find.text('Add Friend'), findsOneWidget);
        await tester.tap(find.text('Add Friend'));
        await tester.pump();

        expect(find.text('Accepting this buddy request…'), findsOneWidget);
        expect(controller.acceptCallCount, 1);

        controller.completeAccept(true);
        await tester.pumpAndSettle();

        expect(find.text('Accepting this buddy request…'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
