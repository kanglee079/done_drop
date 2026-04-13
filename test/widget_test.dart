import 'package:flutter_test/flutter_test.dart';
import 'package:done_drop/app/app.dart';

void main() {
  // Widget smoke test uses runAsync to prevent pending-timer errors.
  // DoneDropApp initializes Firebase + Hive at runtime (in main.dart), not at
  // widget construction time, so the widget itself is just a GetMaterialApp.
  // The real test coverage is in the model unit tests (14 tests).
  testWidgets('DoneDrop app widget smoke test', (WidgetTester tester) async {
    await tester.runAsync(() async {
      // Just verify the widget can be instantiated without throwing
      // (Firebase/Hive are initialized in main.dart, not here)
      await tester.pumpWidget(const DoneDropApp());
      await tester.pump();
      // Verify splash screen text is visible
      expect(find.text('DoneDrop'), findsOneWidget);
    });
  });
}
