import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/data.dart';
import 'package:lamma/l10n/app_localizations.dart';
import 'package:lamma/main.dart';
import 'package:lamma/widgets.dart';

void main() {
  testWidgets('tapping the count opens the list of people in the same page', (
    t,
  ) async {
    seedSample();
    await t.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PeopleExpand(
            names: const ['سارة', 'يوسف'],
            header: const Text('٢ من ٦ حاضرين'),
          ),
        ),
      ),
    );
    expect(find.byType(PeopleList), findsNothing);
    await t.tap(find.text('٢ من ٦ حاضرين'));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.byType(PeopleList), findsOneWidget);
    expect(find.text('سارة'), findsOneWidget);
    expect(find.text('يوسف'), findsOneWidget);
    await t.tap(find.text('٢ من ٦ حاضرين'));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.byType(PeopleList), findsNothing);
  });

  testWidgets('Home: the hero card count opens who is coming', (t) async {
    seedSample();
    await t.binding.setSurfaceSize(const Size(400, 1500));
    await t.pumpWidget(
      const LammaApp(
        skipSplash: true,
        skipOnboarding: true,
        demoNotifications: false,
      ),
    );
    await t.pump(const Duration(seconds: 1));
    expect(find.byType(PeopleList), findsNothing);
    await t.tap(find.byType(PeopleExpand).first);
    await t.pump(const Duration(milliseconds: 300));
    expect(find.byType(PeopleList), findsOneWidget);
  });
}
