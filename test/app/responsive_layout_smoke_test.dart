import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/presentation/onboarding/onboarding_screen.dart';
import 'package:done_drop/app/presentation/premium/premium_screen.dart';
import 'package:done_drop/features/auth/data/onboarding_service.dart';
import 'package:done_drop/features/auth/presentation/controllers/onboarding_controller.dart';

Future<void> _pumpResponsiveApp(
  WidgetTester tester, {
  required Size size,
  required Widget child,
  double textScale = 1.0,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    GetMaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    Get.reset();
  });

  group('Responsive smoke', () {
    testWidgets(
      'OnboardingScreen survives portrait and landscape phone sizes',
      (tester) async {
        final onboardingService = OnboardingService();
        onboardingService.configureWithPrefs(
          await SharedPreferences.getInstance(),
        );
        Get.put<OnboardingController>(OnboardingController(onboardingService));

        await _pumpResponsiveApp(
          tester,
          size: const Size(320, 568),
          child: const OnboardingScreen(),
        );
        expect(tester.takeException(), isNull);

        await _pumpResponsiveApp(
          tester,
          size: const Size(568, 320),
          child: const OnboardingScreen(),
          textScale: 1.3,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('PremiumScreen survives small landscape with larger text', (
      tester,
    ) async {
      await _pumpResponsiveApp(
        tester,
        size: const Size(568, 320),
        textScale: 1.4,
        child: const PremiumScreen(),
      );

      expect(find.textContaining('Premium'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Bottom nav does not throw on narrow width with large text', (
      tester,
    ) async {
      await _pumpResponsiveApp(
        tester,
        size: const Size(320, 640),
        textScale: 1.5,
        child: Scaffold(
          bottomNavigationBar: DDBottomNavBar(currentIndex: 0, onTap: (_) {}),
        ),
      );

      expect(find.byIcon(Icons.today), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
