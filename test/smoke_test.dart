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
  await t.tap(find.byTooltip('رجوع').last);
  await t.pumpAndSettle();
}

void main() {
  testWidgets('all tabs and key screens render', (t) async {
    await t.binding.setSurfaceSize(const Size(400, 850));
    await t.pumpWidget(const LammaApp(skipOnboarding: true));
    for (final label in ['لمّه', 'الأنشطة', 'الحساب', 'الرئيسية']) {
      await tapText(t, label, last: true);
    }
    // home screens
    for (final s in ['ابدأ الاستماع', 'أسبوعك في لمّه']) {
      await tapText(t, s);
      await back(t);
    }
    await tapText(t, 'خرجة إلى القرية');
    await tapText(t, 'أنت مشارك');
    await back(t);
    await t.drag(find.byType(ListView).first, const Offset(0, 2000));
    await t.pumpAndSettle();
    await tapText(t, '+ إضافة فعالية');
    await back(t);
    // lamma
    await tapText(t, 'لمّه', last: true);
    await tapText(t, 'فتح محادثة العائلة');
    await back(t);
    await tapText(t, 'سارة');
    await back(t);
    await t.drag(find.byType(ListView).first, const Offset(0, 2000));
    await t.pumpAndSettle();
    await tapText(t, '+ شارك لحظة');
    await back(t);
    // activities
    await tapText(t, 'الأنشطة', last: true);
    for (final s in ['ألعاب جماعية', 'نادي الكتاب', 'نادي البودكاست', 'مواضيع للحديث', 'الخرجات']) {
      await tapText(t, s);
      if (s == 'ألعاب جماعية') {
        await tapText(t, 'الروليت');
        await tapText(t, 'دور العجلة');
        await t.pump(const Duration(seconds: 4));
        await back(t);
        await tapText(t, 'ابدأ اللعب');
        await tapText(t, 'التالي');
        await back(t);
      }
      if (s == 'الخرجات') {
        await tapText(t, 'حديقة الملك سلمان');
        await tapText(t, 'إضافة إلى «خرجاتنا»');
        await back(t);
      }
      await back(t);
    }
    // account
    await tapText(t, 'الحساب', last: true);
    await tapText(t, 'صمم شخصيتك');
    await back(t);
    await tapText(t, 'كل الأوسمة والإنجازات');
    expect(t.takeException(), isNull);
  });

  testWidgets('onboarding creates a profile and enters the app', (t) async {
    await t.binding.setSurfaceSize(const Size(400, 850));
    await t.pumpWidget(const LammaApp(skipSplash: true));
    await tapText(t, 'ابدأ');
    await t.enterText(find.byType(TextField).first, 'Reem');
    await t.pump();
    await tapText(t, 'طالب/ة');
    await tapText(t, 'التالي');
    await tapText(t, 'قهوة');
    await tapText(t, 'التالي');
    await t.enterText(find.byType(TextField).first, '0500000000');
    await t.pump();
    await tapText(t, 'إنشاء حساب');
    await t.enterText(find.byType(TextField).first, 'Test family');
    await t.pump();
    await tapText(t, 'إنشاء');
    await tapText(t, 'يلا نبدأ');
    expect(find.text('مساء الخير، Reem'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
