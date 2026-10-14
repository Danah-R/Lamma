import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/data.dart';
import 'package:lamma/main.dart';

void main() {
  testWidgets('the profile can show and hide the whole family', (t) async {
    seedSample();
    await t.binding.setSurfaceSize(const Size(400, 1600));
    await t.pumpWidget(
      const LammaApp(
        skipSplash: true,
        skipOnboarding: true,
        demoNotifications: false,
      ),
    );
    await t.pump(const Duration(seconds: 1));
    await t.tap(find.byTooltip('الحساب'));
    await t.pump(const Duration(milliseconds: 500));
    await t.dragUntilVisible(
      find.text('عرض كل أفراد العائلة (6)'),
      find.byType(Scrollable).first,
      const Offset(0, -300),
    );
    expect(find.text('إخفاء القائمة'), findsNothing);
    await t.tap(find.text('عرض كل أفراد العائلة (6)'));
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('إخفاء القائمة'), findsOneWidget);
    // every member is listed with their role
    await t.dragUntilVisible(
      find.text('عبدالله').last,
      find.byType(Scrollable).first,
      const Offset(0, -200),
    );
    expect(find.text('عبدالله'), findsWidgets);
    await t.tap(find.text('إخفاء القائمة'));
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('إخفاء القائمة'), findsNothing);
  });
}
