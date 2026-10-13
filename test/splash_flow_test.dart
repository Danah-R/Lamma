// The splash opens on every cold start; START_AT_HOME only skips onboarding.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/main.dart';
import 'package:lamma/screens/onboarding.dart';
import 'package:lamma/splash/lamma_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'moments_coach_seen': true});
    // the camera ring pulses forever: reduced motion lets pumpAndSettle end
    TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
      disableAnimations: true,
    );
  });
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher
        .clearAccessibilityFeaturesTestValue();
  });

  /// The splash waits for its images (real async), then runs by itself.
  Future<void> until(WidgetTester t, Finder f) async {
    for (var i = 0; i < 120 && f.evaluate().isEmpty; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await t.pump(const Duration(milliseconds: 250));
    }
  }

  testWidgets('a signed-in launch: splash first, then home', (t) async {
    await t.binding.setSurfaceSize(const Size(390, 844));
    await t.pumpWidget(const LammaApp(skipOnboarding: true));
    await t.pump(const Duration(milliseconds: 100));
    expect(find.byType(LammaSplash), findsOneWidget);
    expect(find.byType(Shell), findsNothing);
    // the splash hands over by itself
    await until(t, find.byType(Shell));
    expect(find.byType(Shell), findsOneWidget);
    expect(find.byType(OnboardingFlow), findsNothing);
  });

  testWidgets('a new user: splash first, then onboarding', (t) async {
    await t.binding.setSurfaceSize(const Size(390, 844));
    await t.pumpWidget(const LammaApp());
    await t.pump(const Duration(milliseconds: 100));
    expect(find.byType(LammaSplash), findsOneWidget);
    for (
      var i = 0;
      i < 80 && find.byType(OnboardingFlow).evaluate().isEmpty;
      i++
    ) {
      await t.pump(const Duration(milliseconds: 250));
    }
    expect(find.byType(OnboardingFlow), findsOneWidget);
    expect(find.byType(Shell), findsNothing);
  });

  testWidgets('tests can still skip the splash', (t) async {
    await t.binding.setSurfaceSize(const Size(390, 844));
    await t.pumpWidget(const LammaApp(skipSplash: true, skipOnboarding: true));
    await t.pumpAndSettle();
    expect(find.byType(LammaSplash), findsNothing);
    expect(find.byType(Shell), findsOneWidget);
  });
}
