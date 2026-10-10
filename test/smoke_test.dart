import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:lamma/data.dart';
import 'package:lamma/features/clubs/clubs_controller.dart';
import 'package:lamma/features/clubs/widgets/book_suggestion_tile.dart';
import 'package:lamma/features/games/who_am_i/who_am_i_screen.dart';
import 'package:lamma/l10n/data_localizations.dart';
import 'package:lamma/main.dart';

Future<void> tapText(
  WidgetTester t,
  String s, {
  bool last = false,
  bool clear = false,
}) async {
  final f = last ? find.text(s).last : find.text(s).first;
  if (f.evaluate().isEmpty) {
    await t.scrollUntilVisible(
      f,
      300,
      scrollable: find.byType(Scrollable).first,
    );
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
    // tonight's topic card opens the talk-topics flow
    await tapText(t, 'يلا نسولف');
    await back(t);
    // games: "عرض الكل" opens the games listing (roulette + Aziz/Sin Jim cards)
    await tapText(t, 'عرض الكل');
    await tapText(t, 'الروليت');
    await t.tap(find.text('دور العجلة').first);
    await t.pump();
    await t.pump(const Duration(seconds: 4));
    await t.tap(find.text('تمام').first);
    await t.pumpAndSettle();
    await back(t);
    await tapText(t, 'حروف مع عزيز'); // "coming soon" game: snackbar only
    expect(find.text('قريبًا! نجهّزها لكم'), findsOneWidget);
    await t.ensureVisible(find.text('مين أنا؟').first);
    await t.pump();
    await t.tap(find.text('مين أنا؟').first);
    // the intro's floating cards animate forever, so no pumpAndSettle here
    await t.pump(const Duration(milliseconds: 600));
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('يلا نبدأ'), findsOneWidget);
    await t.tap(
      find.descendant(
        of: find.byType(WhoAmIScreen),
        matching: find.byIcon(Icons.chevron_right_rounded),
      ),
    );
    await t.pump(const Duration(milliseconds: 600));
    await t.pump(const Duration(milliseconds: 600));
    expect(find.byType(WhoAmIScreen), findsNothing);
    await back(t);
    // clubs: the Activities preview cards and ClubsScreen share one
    // controller — progress/votes/suggestions/heard must survive leaving
    // and re-entering the screen.
    final clubs = Provider.of<ClubsController>(
      t.element(find.byType(MaterialApp)),
      listen: false,
    );
    await tapText(t, 'العادات الذرية');
    await tapText(t, 'سجّل وين وصلت');
    await tapText(t, 'خلّصته');
    await tapText(t, 'حفظ');
    expect(clubs.myBookProgress, 1.0);
    await t.tap(find.byType(VoteButton).first);
    await t.pump();
    expect(clubs.bookVotes.contains(0), isTrue);
    final suggestionsBefore = clubs.bookSuggestions.length;
    await tapText(t, 'اقترح كتاب', last: true);
    await t.enterText(find.byType(TextField).first, 'كتاب الاختبار');
    await t.pump();
    await tapText(t, 'رواية');
    await tapText(t, 'أضف للمقترحات');
    expect(clubs.bookSuggestions.length, suggestionsBefore + 1);
    expect(clubs.bookSuggestions.last.title, 'كتاب الاختبار');
    await back(t);
    expect(clubs.myBookProgress, 1.0);
    expect(clubs.bookVotes.contains(0), isTrue);
    expect(clubs.bookSuggestions.length, suggestionsBefore + 1);
    await tapText(t, 'التحرر من التشتت');
    await tapText(t, 'سمعتها');
    expect(clubs.iHeard, isTrue);
    await back(t);
    expect(clubs.iHeard, isTrue);
    // weekend outing: voting toggles the button label
    await tapText(t, 'بجي معكم!');
    expect(find.text('صوّتت معهم'), findsOneWidget);
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
