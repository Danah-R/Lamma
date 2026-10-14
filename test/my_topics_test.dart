import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/data.dart';
import 'package:lamma/features/topics/topics_controller.dart';
import 'package:lamma/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a topic I add is first in tonight\'s topics and in my topics, and leaves when discussed', () {
    final c = TopicsController();
    final before = c.tonightTopics.length;
    c.addMyTopic('وش نسوي بالإجازة؟', select: false);
    expect(
      c.selectedCategory,
      isNull,
      reason: 'adding from Home does not move the deck',
    );
    expect(c.myPendingTopics.map((t) => t.text), ['وش نسوي بالإجازة؟']);
    expect(c.tonightTopics.first.text, 'وش نسوي بالإجازة؟');
    expect(c.tonightTopics.length, before + 1);
    // it is also in the topics screen's "our topics" group
    expect(c.myTopics.single.text, 'وش نسوي بالإجازة؟');
    expect(c.categories.map((x) => x.id), contains('mine'));

    // newest first
    c.addMyTopic('ثاني', select: false);
    expect(c.myPendingTopics.map((t) => t.text), ['ثاني', 'وش نسوي بالإجازة؟']);

    // once the family talked about it, it leaves the profile list and tonight's topics
    c.markDiscussed(c.myTopics.first.id);
    expect(c.myPendingTopics.map((t) => t.text), ['ثاني']);
    expect(
      c.tonightTopics.map((t) => t.text),
      isNot(contains('وش نسوي بالإجازة؟')),
    );
  });

  test('my topics are remembered on the phone', () async {
    final a = TopicsController();
    a.addMyTopic('موضوع محفوظ', select: false);
    a.addMyTopic('تم الكلام فيه', select: false);
    a.markDiscussed(a.myTopics.last.id);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final b = TopicsController();
    await b.load();
    expect(b.myTopics.map((t) => t.text), ['موضوع محفوظ', 'تم الكلام فيه']);
    expect(b.myPendingTopics.map((t) => t.text), ['موضوع محفوظ']);
  });

  testWidgets(
    'Home has the box, and the profile lists the topic until it is discussed',
    (t) async {
      seedSample();
      await t.binding.setSurfaceSize(const Size(400, 2400));
      await t.pumpWidget(
        const LammaApp(
          skipSplash: true,
          skipOnboarding: true,
          demoNotifications: false,
        ),
      );
      await t.pump(const Duration(seconds: 1));
      expect(find.text('في سالفة ببالك؟'), findsOneWidget);
      await t.enterText(
        find.widgetWithText(TextField, 'اكتب موضوع…'),
        'رحلة الصيف',
      );
      await t.tap(find.text('أضف'));
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('انضاف لسوالف الليلة'), findsOneWidget);

      await t.tap(find.byTooltip('الحساب'));
      await t.pump(const Duration(milliseconds: 500));
      await t.dragUntilVisible(
        find.text('مواضيعي'),
        find.byType(Scrollable).first,
        const Offset(0, -300),
      );
      expect(find.text('رحلة الصيف'), findsOneWidget);
    },
  );
}
