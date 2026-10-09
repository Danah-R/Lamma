import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/data.dart';
import 'package:lamma/l10n/data_localizations.dart';
import 'package:lamma/main.dart';

Future<void> tapText(WidgetTester t, String s, {bool last = false, bool clear = false}) async {
  final f = last ? find.text(s).last : find.text(s).first;
  if (f.evaluate().isEmpty) {
    await t.scrollUntilVisible(f, 300, scrollable: find.byType(Scrollable).first);
  }
  await t.ensureVisible(f);
  await t.pumpAndSettle();
  if (clear) {
    // lift it above the floating bar
    await t.drag(find.byType(ListView).first, const Offset(0, -200));
    await t.pumpAndSettle();
  }
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
    for (final label in ['لمّه', 'صندوق الأنشطة', 'الحساب', 'الرئيسية']) {
      await tapText(t, label, last: true);
    }
    // home screens
    for (final s in ['ابدأ الاستماع', 'أسبوعك في لمّه']) {
      await tapText(t, s);
      await back(t);
    }
    await t.drag(find.byType(ListView).first, const Offset(0, 3000));
    await t.pumpAndSettle();
    await tapText(t, 'خرجة إلى القرية');
    await tapText(t, 'أنت مشارك');
    await back(t);
    await t.drag(find.byType(ListView).first, const Offset(0, 2000));
    await t.pumpAndSettle();
    await tapText(t, '+ إضافة فعالية');
    await t.enterText(find.byType(TextField).first, 'Picnic');
    await t.pump();
    final dateContext = t.element(find.byType(Scaffold).first);
    await tapText(t, localizedDateLabel(dateContext, DateTime.now()));
    await tapText(t, 'حسنًا');
    await tapText(t, 'إضافة إلى التقويم');
    await t.drag(find.byType(ListView).first, const Offset(0, 2000));
    await t.pumpAndSettle();
    expect(find.text('Picnic'), findsOneWidget);
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
    await tapText(t, 'صندوق الأنشطة', last: true);
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
    await t.enterText(find.byType(TextField).at(1), '17');
    await t.pump();
    await tapText(t, 'أم');
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
    expect(profile.isParent, isTrue);

    // parent controls: record a violation (lose points), then reward #1
    final before = members.firstWhere((m) => m.key == 'girl').points;
    await tapText(t, 'الحساب', last: true);
    await tapText(t, 'ضوابط الوالدين');
    await tapText(t, 'سارة');
    await tapText(t, 'اخصم 10 نقاط');
    expect(members.firstWhere((m) => m.key == 'girl').points, before - 10);
    await t.drag(find.byType(ListView).first, const Offset(0, 3000));
    await t.pumpAndSettle();
    await tapText(t, 'عقوبة');
    await tapText(t, 'يوسف');
    await tapText(t, 'طبّق العقوبة');
    expect(rules.punishments['Yousef'], isNotNull);
    await t.drag(find.byType(ListView).first, const Offset(0, -3000));
    await t.pumpAndSettle();
    await tapText(t, 'شهرية');
    expect(rules.cycle, 'Monthly');
    await t.pump(const Duration(seconds: 6)); // let the snackbar go away
    await t.pumpAndSettle();
    await tapText(t, 'كافئ سارة (الأول) الحين', clear: true);
    expect(rules.lastWinner, 'Sarah');
    expect(t.takeException(), isNull);
  });
}
