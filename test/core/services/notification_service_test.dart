import 'package:flutter_test/flutter_test.dart';
import 'package:done_drop/core/services/notification_service.dart';

void main() {
  test('NotificationService keeps a stable singleton instance', () {
    expect(
      identical(NotificationService.instance, NotificationService.instance),
      isTrue,
    );
  });
}
