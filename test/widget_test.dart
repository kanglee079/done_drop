import 'package:flutter_test/flutter_test.dart';
import 'package:done_drop/app/app.dart';

void main() {
  testWidgets('DoneDrop app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DoneDropApp());
    await tester.pump();
    // Verify app renders without crashing
    expect(find.text('DoneDrop'), findsAny);
  });
}
