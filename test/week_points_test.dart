import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/data.dart';
import 'package:lamma/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('the big card shows my points this week, and tapping it opens the leaderboard', (t) async {
    SharedPreferences.setMockInitialValues({});
    seedSample();
    await t.binding.setSurfaceSize(const Size(400, 1400));
    await t.pumpWidget(const LammaApp(skipSplash: true, skipOnboarding: true, demoNotifications: false));
    await t.pump(const Duration(seconds: 1));
    // a new week starts from today's total, so nothing yet
    expect(find.text('ما جبت نقاط هالأسبوع للحين'), findsOneWidget);
    // earn some: it shows up
    addPoints(profile.name, 12);
    sharedTick.value++;
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('12 نقطة هالأسبوع'), findsOneWidget);
    await t.tap(find.text('12 نقطة هالأسبوع'));
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('الترتيب'), findsWidgets); // the leaderboard page
  });
}
