// Drives the real onboarding screens against the real Supabase project:
//   LIVE_BACKEND=1 LIVE_FLOW=create flutter test test/backend_ui_live_test.dart
// (Joining is covered, with two separate clients, by backend_live_test.dart.)
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/backend/backend.dart';
import 'package:lamma/data.dart';
import 'package:lamma/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void phase(String m) => debugPrint('PHASE $m');

/// pumpAndSettle that gives up after 3 seconds instead of waiting forever.
Future<void> pumpS(WidgetTester t) async {
  try {
    await t.pumpAndSettle(const Duration(milliseconds: 100), EnginePhase.sendSemanticsUpdate, const Duration(seconds: 3));
  } catch (_) {}
}

/// Waits (real time) until [done] is true, for at most ~40 seconds.
Future<void> until(WidgetTester t, bool Function() done) async {
  for (var i = 0; i < 80 && !done(); i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 500)));
    await t.pump(const Duration(milliseconds: 100));
  }
}

Future<void> settle(WidgetTester t, {int ms = 500, int rounds = 24}) async {
  for (var i = 0; i < rounds; i++) {
    await t.runAsync(() => Future<void>.delayed(Duration(milliseconds: ms)));
    await t.pump(const Duration(milliseconds: 200));
  }
}

Future<void> tapT(WidgetTester t, String s) async {
  final f = find.text(s).first;
  await t.ensureVisible(f);
  await pumpS(t);
  await t.tap(f);
  await pumpS(t);
}

Future<void> next(WidgetTester t) async {
  await t.tap(find.byKey(const Key('onboarding-next')));
  await pumpS(t);
}

/// Fills the first page and the interests page. Role: 'أم' (mom) or 'ابنة' (daughter).
Future<void> aboutAndInterests(WidgetTester t, String name, String role) async {
  await t.enterText(find.byType(TextField).at(0), name);
  await t.enterText(find.byType(TextField).at(1), '30');
  await t.pump();
  await tapT(t, role);
  await tapT(t, 'طالب/ة');
  await tapT(t, 'نعم');
  await t.enterText(find.byType(TextField).at(2), '0555555555');
  await t.pump();
  await next(t);
  await tapT(t, 'قهوة');
  await next(t);
}

void main() {
  final live = Platform.environment['LIVE_BACKEND'] == '1';
  final flow = Platform.environment['LIVE_FLOW'];  // must be 'create'

  testWidgets('create: onboarding makes a family in the database', (t) async {
    HttpOverrides.global = null;
    SharedPreferences.setMockInitialValues({});
    await t.binding.setSurfaceSize(const Size(400, 850));
    await t.runAsync(() async => Backend.init());

    await t.pumpWidget(const LammaApp(skipSplash: true));
    await aboutAndInterests(t, 'Amina', 'أم');
    await t.enterText(find.byType(TextField).first, 'UI test family');
    await t.pump();
    await tapT(t, 'إنشاء'); // Create
    await next(t); // character -> finish
    await until(t, () => profile.memberId != null);
    expect(profile.memberId, isNotNull, reason: 'the family should exist in the database');
    expect(profile.family, 'UI test family');
    expect(profile.familyCode, startsWith('LAMMA-'));
    expect(profile.isParent, isTrue);
    expect(find.text('هلا، Amina'), findsOneWidget, reason: 'the app opens on Home');
    // let the test binding finish cleanly: close the network client and flush timers
    await t.pumpWidget(const SizedBox());
    await t.runAsync(() => Supabase.instance.dispose());
    await t.pump(const Duration(seconds: 30));
  }, skip: !live || flow != 'create');
}
