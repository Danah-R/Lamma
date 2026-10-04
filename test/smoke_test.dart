import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/main.dart';

Future<void> tapText(WidgetTester t, String s, {bool last = false}) async {
  final f = last ? find.text(s).last : find.text(s).first;
  await t.ensureVisible(f);
  await t.pumpAndSettle();
  await t.tap(f);
  await t.pumpAndSettle();
}

Future<void> back(WidgetTester t) async {
  await t.tap(find.byTooltip('Back').last);
  await t.pumpAndSettle();
}

void main() {
  testWidgets('all tabs and key screens render', (t) async {
    await t.binding.setSurfaceSize(const Size(400, 850));
    await t.pumpWidget(const LammaApp(skipOnboarding: true));
    for (final label in ['Lamma', 'Activities', 'Account', 'Home']) {
      await tapText(t, label, last: true);
    }
    // home screens
    for (final s in ['Start listening', 'Your week in Lamma']) {
      await tapText(t, s);
      await back(t);
    }
    await tapText(t, 'Village outing');
    await tapText(t, "You're in");
    await back(t);
    await t.drag(find.byType(ListView).first, const Offset(0, 2000));
    await t.pumpAndSettle();
    await tapText(t, '+ Add event');
    await back(t);
    // lamma
    await tapText(t, 'Lamma', last: true);
    await tapText(t, 'Open family chat');
    await back(t);
    await tapText(t, 'Sarah');
    await back(t);
    await t.drag(find.byType(ListView).first, const Offset(0, 2000));
    await t.pumpAndSettle();
    await tapText(t, '+ Share moment');
    await back(t);
    // activities
    await tapText(t, 'Activities', last: true);
    for (final s in ['Group games', 'Book club', 'Podcast club', 'Talk topics', 'Outings']) {
      await tapText(t, s);
      if (s == 'Group games') {
        await tapText(t, 'Roulette');
        await tapText(t, 'Spin the wheel');
        await t.pump(const Duration(seconds: 4));
        await back(t);
        await tapText(t, 'Start playing');
        await tapText(t, 'Next');
        await back(t);
      }
      if (s == 'Outings') {
        await tapText(t, 'King Salman Park');
        await tapText(t, 'Add to "Our outings"');
        await back(t);
      }
      await back(t);
    }
    // account
    await tapText(t, 'Account', last: true);
    await tapText(t, 'Design your character');
    await back(t);
    await tapText(t, 'All badges and achievements');
    expect(t.takeException(), isNull);
  });

  testWidgets('onboarding creates a profile and enters the app', (t) async {
    await t.binding.setSurfaceSize(const Size(400, 850));
    await t.pumpWidget(const LammaApp());
    await tapText(t, 'Start');
    await t.enterText(find.byType(TextField).first, 'Reem');
    await t.pump();
    await tapText(t, "I'm a student");
    await tapText(t, 'Next');
    await tapText(t, 'Coffee');
    await tapText(t, 'Next');
    await t.enterText(find.byType(TextField).first, '0500000000');
    await t.pump();
    await tapText(t, 'Create account');
    await t.enterText(find.byType(TextField).first, 'Test family');
    await t.pump();
    await tapText(t, 'Create');
    await tapText(t, "Let's go");
    expect(find.text('Good evening, Reem'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
