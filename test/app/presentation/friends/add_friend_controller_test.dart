import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:done_drop/app/presentation/friends/add_friend_controller.dart';
import 'package:done_drop/core/models/user_profile.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';

class _FakeFirestore implements FirebaseFirestore {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PrefillTestController extends AddFriendController {
  _PrefillTestController() : super(FriendRepository(_FakeFirestore()));

  int searchByCodeCalls = 0;
  int sendRequestCalls = 0;
  String? lastCode;
  bool shouldResolveUser = true;
  bool shouldReturnError = false;

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  // ignore: must_call_super
  void onReady() {}

  @override
  Future<void> searchByCode(String code) async {
    searchByCodeCalls += 1;
    lastCode = code;
    foundUser.value = shouldResolveUser
        ? UserProfile(
            id: 'buddy-qr',
            displayName: 'QR Buddy',
            userCode: 'AB12CD',
            createdAt: DateTime(2024, 4, 21),
          )
        : null;
    errorMessage.value = shouldReturnError ? 'Buddy not found' : null;
    requestSent.value = false;
    isSearching.value = false;
  }

  @override
  Future<void> sendRequest() async {
    sendRequestCalls += 1;
    requestSent.value = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('AddFriendController.applyNavigationPrefill', () {
    test('auto-sends when QR prefill resolves a user', () async {
      final controller = _PrefillTestController();

      await controller.applyNavigationPrefill(
        prefillCode: 'ab-12 cd',
        autoSend: true,
      );

      expect(controller.searchByCodeCalls, 1);
      expect(controller.lastCode, 'AB12CD');
      expect(controller.sendRequestCalls, 1);
      expect(controller.requestSent.value, isTrue);
    });

    test('does not auto-send when autoSend is false', () async {
      final controller = _PrefillTestController();

      await controller.applyNavigationPrefill(
        prefillCode: 'ab-12 cd',
        autoSend: false,
      );

      expect(controller.searchByCodeCalls, 1);
      expect(controller.sendRequestCalls, 0);
      expect(controller.requestSent.value, isFalse);
    });

    test('does not auto-send when prefill search returns an error', () async {
      final controller = _PrefillTestController()
        ..shouldResolveUser = false
        ..shouldReturnError = true;

      await controller.applyNavigationPrefill(
        prefillCode: 'ab-12 cd',
        autoSend: true,
      );

      expect(controller.searchByCodeCalls, 1);
      expect(controller.sendRequestCalls, 0);
      expect(controller.errorMessage.value, 'Buddy not found');
      expect(controller.requestSent.value, isFalse);
    });
  });
}
