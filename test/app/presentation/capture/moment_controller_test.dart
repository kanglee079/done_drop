import 'package:flutter_test/flutter_test.dart';
import 'package:done_drop/app/presentation/capture/moment_controller.dart';
import 'package:done_drop/core/constants/app_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MomentController session reset', () {
    test('clears stale proof context when a new free capture starts', () {
      final controller = MomentController(
        warmPreparedUpload: (_) {},
        discardPreparedUpload: (_) {},
      );

      controller.startCaptureSession({
        'activityId': 'habit-1',
        'activityInstanceId': 'inst-1',
        'completionLogId': 'log-1',
      });
      controller.attachImage('/tmp/proof.jpg');
      controller.setCategory('Exercise');
      controller.setVisibility(AppConstants.visibilitySelectedFriends);
      controller.toggleSelectedFriend('friend-1');
      controller.captionController.text = 'done';

      controller.startCaptureSession(null);

      expect(controller.isProofMoment, isFalse);
      expect(controller.activityId, isNull);
      expect(controller.activityInstanceId, isNull);
      expect(controller.completionLogId, isNull);
      expect(controller.imagePath, isNull);
      expect(controller.selectedFriendIds, isEmpty);
      expect(controller.selectedCategory.value, isEmpty);
      expect(controller.captionController.text, isEmpty);
    });

    test('resetComposer clears a finished session', () {
      final controller = MomentController(
        warmPreparedUpload: (_) {},
        discardPreparedUpload: (_) {},
      );

      controller.startCaptureSession({
        'activityId': 'habit-1',
        'activityInstanceId': 'inst-1',
        'completionLogId': 'log-1',
      });
      controller.attachImage('/tmp/proof.jpg');

      controller.resetComposer();

      expect(controller.isProofMoment, isFalse);
      expect(controller.imagePath, isNull);
      expect(controller.lastSubmission.value, isNull);
    });
  });
}
