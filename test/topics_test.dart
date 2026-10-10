import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:lamma/features/topics/topics_controller.dart';
import 'package:lamma/features/topics/topics_screen.dart';
import 'package:lamma/features/topics/widgets/category_chips.dart';
import 'package:lamma/features/topics/widgets/discussed_section.dart';
import 'package:lamma/l10n/app_localizations.dart';
import 'package:lamma/main.dart';
import 'package:lamma/widgets/topic_deck_card.dart';

Widget _app(TopicsController c, Widget home) => ChangeNotifierProvider.value(
  value: c,
  child: MaterialApp(
    locale: const Locale('ar'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  ),
);

Future<void> _settle(WidgetTester t) async {
  for (var i = 0; i < 6; i++) {
    await t.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  group('TopicsController', () {
    test('categories, filtering, navigation', () {
      final c = TopicsController();
      expect(c.visibleTopics.length, 20);
      expect(c.categories.map((x) => x.id), isNot(contains('mine')));
      c.selectCategory('food');
      expect(c.visibleTopics.length, 4);
      expect(c.currentIndex, 0);
      c.prev();
      expect(c.currentIndex, 3);
      c.next();
      expect(c.currentIndex, 0);
      c.selectCategory(null);
      expect(c.visibleTopics.length, 20);
    });

    test('save, discussed order, my topics, openTopic', () {
      final c = TopicsController();
      c.toggleSave('b3');
      expect(c.isSaved('b3'), isTrue);
      c.toggleSave('b3');
      expect(c.isSaved('b3'), isFalse);
      c.markDiscussed('b1');
      c.markDiscussed('b2');
      c.markDiscussed('b1'); // no duplicate
      expect(c.discussedIds, ['b2', 'b1']);
      c.addMyTopic('  وش أول راتب استلمته؟ ');
      c.addMyTopic('   ');
      expect(c.myTopics.length, 1);
      expect(c.selectedCategory, 'mine');
      expect(c.categories.last.id, 'mine');
      c.openTopic('b6');
      expect(c.selectedCategory, 'dreams');
      expect(c.currentIndex, 2);
      expect(c.visibleTopics[c.currentIndex].id, 'b6');
    });
  });

  testWidgets('topics screen: header, chips, deck, save, talk, next', (
    t,
  ) async {
    await t.binding.setSurfaceSize(const Size(400, 850));
    final c = TopicsController();
    await t.pumpWidget(_app(c, const TopicsScreen()));
    await _settle(t);

    expect(find.text('مواضيع للحديث'), findsOneWidget);
    expect(find.text('افتحوا سالفة، والباقي عليكم'), findsOneWidget);
    expect(find.text('الكل'), findsOneWidget);
    expect(find.text('مواضيعنا'), findsNothing);
    expect(find.text('1 من 20'), findsOneWidget);

    await t.scrollUntilVisible(
      find.text('أكل'),
      100,
      scrollable: find.descendant(
        of: find.byType(CategoryChips),
        matching: find.byType(Scrollable),
      ),
    );
    await t.ensureVisible(find.text('أكل'));
    await t.pump();
    await t.tap(find.text('أكل'));
    await _settle(t);
    expect(c.selectedCategory, 'food');
    expect(find.text('1 من 4'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(TopicDeckCard),
        matching: find.text('وش أكلة أمي المفضلة عندك؟'),
      ),
      findsOneWidget,
    );

    // save toggles
    await t.tap(find.byIcon(Icons.bookmark_border_rounded));
    await t.pump();
    expect(c.isSaved('b8'), isTrue);
    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);

    // talk -> discussed badge + button state
    expect(find.text('سولفتوا فيه'), findsNothing);
    await t.tap(find.text('يلا نسولف'));
    await t.pump();
    expect(find.text('سولفتوا فيه'), findsOneWidget);
    expect(find.text('سولفنا فيه ✓'), findsOneWidget);

    // next ("غيّرها") flies the card, then shows topic 2
    await t.tap(find.text('غيّرها'));
    await _settle(t);
    expect(find.text('2 من 4'), findsOneWidget);
    expect(find.text('لو تاكل أكلة وحدة طول حياتك، وش هي؟'), findsOneWidget);
    expect(c.currentIndex, 1);

    // previous goes back
    await t.tap(find.byIcon(Icons.arrow_forward_rounded));
    await _settle(t);
    expect(find.text('1 من 4'), findsOneWidget);
    expect(c.currentIndex, 0);
  });

  testWidgets('adding my topic shows the "مواضيعنا" chip', (t) async {
    await t.binding.setSurfaceSize(const Size(400, 850));
    final c = TopicsController();
    await t.pumpWidget(_app(c, const TopicsScreen()));
    c.addMyTopic('سالفتنا');
    await _settle(t);
    expect(find.text('مواضيعنا'), findsOneWidget);
    expect(find.text('سالفتنا'), findsOneWidget);
    expect(find.text('1 من 1'), findsOneWidget);
  });

  testWidgets('home "tonight" card keeps its original look', (t) async {
    await t.binding.setSurfaceSize(const Size(400, 850));
    await t.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: TopicDeckCard(topics: const ['أ', 'ب', 'ج', 'د']),
          ),
        ),
      ),
    );
    await _settle(t);
    // classic card: tag, buttons, 262 high card, no category/save controls.
    expect(find.text('سالفة الليلة'), findsOneWidget);
    expect(find.text('يلا نسولف'), findsOneWidget);
    expect(find.text('غيّرها'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border_rounded), findsNothing);
    final deck = t.getSize(find.byType(TopicDeckCard));
    expect(deck.height, 262 + 18);
  });

  testWidgets('trending, suggest and discussed sections', (t) async {
    await t.binding.setSurfaceSize(const Size(400, 850));
    final c = TopicsController();
    await t.pumpWidget(_app(c, const TopicsScreen()));
    await _settle(t);

    // discussed: empty state first
    await t.ensureVisible(find.text('ولا موضوع للحين'));
    await t.pump();
    expect(find.text('ولا موضوع للحين'), findsOneWidget);
    expect(find.textContaining('يتسجّل هنا'), findsOneWidget);

    // trending cards -> openTopic, deck jumps to it
    await t.ensureVisible(find.text('رائج الحين'));
    await t.pump();
    expect(find.text('الأكثر سوالف هالأسبوع'), findsOneWidget);
    expect(find.text('نسولف فيه'), findsWidgets);
    await t.ensureVisible(
      find.text('لو خيّروك بين البحر والبر، وش تختار؟').last,
    );
    await t.pump();
    await t.tap(find.text('لو خيّروك بين البحر والبر، وش تختار؟').last);
    await _settle(t);
    expect(c.selectedCategory, 'wyr');
    expect(c.visibleTopics[c.currentIndex].id, 'b16');
    expect(
      t
          .widget<SingleChildScrollView>(
            find.byType(SingleChildScrollView).first,
          )
          .controller!
          .offset,
      0,
    );

    // suggest: add button disabled until typing
    await t.ensureVisible(find.text('عندك سالفة ببالك؟'));
    await t.pump();
    final field = find.byType(TextField);
    await t.tap(find.text('أضف'));
    await t.pump();
    expect(c.myTopics, isEmpty);
    await t.enterText(field, 'وش أول راتب استلمته؟');
    await t.pump();
    await t.tap(find.text('أضف'));
    await _settle(t);
    expect(c.myTopics.single.text, 'وش أول راتب استلمته؟');
    expect(c.selectedCategory, 'mine');
    expect(t.widget<TextField>(field).controller!.text, '');
    expect(find.text('انضاف موضوعك'), findsOneWidget);
    expect(find.text('مواضيعنا'), findsOneWidget);

    // discussing adds to the list on top, newest first, max 4 shown
    for (final id in ['b0', 'b1', 'b2', 'b3', 'b4']) {
      c.markDiscussed(id);
      await _settle(t);
    }
    await t.ensureVisible(find.text('5 مواضيع'));
    await t.pump();
    expect(find.text('5 مواضيع'), findsOneWidget);
    Finder inList(String text) => find.descendant(
      of: find.byType(DiscussedSection),
      matching: find.text(text),
    );
    expect(inList('لو تقدر تسافر لأي مكان الحين، وين بتروح؟'), findsOneWidget);
    // the first one marked (b0) is the 5th newest and dropped off the list
    expect(inList('وش أحلى ذكرى عندك من رمضان؟'), findsNothing);
  });

  testWidgets('from the Activities tab: bar stays, tab selected', (t) async {
    await t.binding.setSurfaceSize(const Size(400, 850));
    await t.pumpWidget(const LammaApp(skipOnboarding: true));
    await t.pump(const Duration(seconds: 1));
    await t.tap(find.text('صندوق الأنشطة').last);
    await _settle(t);
    await t.tap(find.text('يلا نسولف').first);
    await _settle(t);
    expect(find.text('افتحوا سالفة، والباقي عليكم'), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
    expect(find.byIcon(Icons.widgets_rounded), findsOneWidget);
  });

  /// Every tappable (InkWell) is at least 44x44.
  void checkTargets(WidgetTester t, String where) {
    for (final e in find.byType(InkWell).evaluate()) {
      final box = e.renderObject! as RenderBox;
      expect(
        box.size.width >= 43.5 && box.size.height >= 43.5,
        isTrue,
        reason: '$where: tap target ${box.size}',
      );
    }
  }

  testWidgets('44x44 targets, labels, no overflow at 360', (t) async {
    final h = t.ensureSemantics();
    await t.binding.setSurfaceSize(const Size(360, 640));
    final c = TopicsController();
    await t.pumpWidget(_app(c, const TopicsScreen()));
    await _settle(t);
    checkTargets(t, 'top');
    // icon-only buttons carry Arabic labels
    expect(find.bySemanticsLabel('رجوع'), findsOneWidget);
    expect(find.bySemanticsLabel('احفظ الموضوع'), findsOneWidget);
    expect(find.bySemanticsLabel('الموضوع السابق'), findsOneWidget);
    await t.ensureVisible(find.text('أضف'));
    await t.pump();
    checkTargets(t, 'suggest');
    c.markDiscussed('b0');
    c.toggleSave('b1');
    await _settle(t);
    await t.ensureVisible(find.text('سولفنا فيها'));
    await t.pump();
    checkTargets(t, 'discussed');
    h.dispose();
  });

  testWidgets('saved / discussed survive leaving and coming back', (t) async {
    await t.binding.setSurfaceSize(const Size(400, 850));
    final c = TopicsController();
    await t.pumpWidget(
      _app(
        c,
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const TopicsScreen())),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await _settle(t);
    await t.tap(find.byIcon(Icons.bookmark_border_rounded));
    await t.tap(find.text('يلا نسولف'));
    await _settle(t);
    expect(find.text('سولفنا فيه ✓'), findsOneWidget);
    await t.tap(find.byTooltip('رجوع'));
    await _settle(t);
    await t.tap(find.text('open'));
    await _settle(t);
    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
    expect(find.text('سولفنا فيه ✓'), findsOneWidget);
    expect(find.text('سولفتوا فيه'), findsOneWidget);
  });

  testWidgets('added topics show in the deck (all) and in "مواضيعنا"', (
    t,
  ) async {
    await t.binding.setSurfaceSize(const Size(400, 850));
    final c = TopicsController();
    await t.pumpWidget(_app(c, const TopicsScreen()));
    await _settle(t);
    await t.ensureVisible(find.byType(TextField));
    await t.enterText(find.byType(TextField), 'سالفة جديدة');
    await t.pump();
    await t.tap(find.text('أضف'));
    await _settle(t);
    // now on "مواضيعنا", pointing at the new topic
    expect(find.text('1 من 1'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(TopicDeckCard),
        matching: find.text('سالفة جديدة'),
      ),
      findsOneWidget,
    );
    c.selectCategory(null);
    await _settle(t);
    expect(find.text('1 من 21'), findsOneWidget);
    expect(c.visibleTopics.last.text, 'سالفة جديدة');
    expect(c.visibleTopics.last.isMine, isTrue);
  });

  testWidgets('keyboard does not cover the suggest field', (t) async {
    await t.binding.setSurfaceSize(const Size(360, 640));
    t.view.devicePixelRatio = 3;
    t.view.viewInsets = const FakeViewPadding(bottom: 300 * 3.0);
    addTearDown(t.view.resetViewInsets);
    final c = TopicsController();
    await t.pumpWidget(_app(c, const TopicsScreen()));
    await _settle(t);
    await t.ensureVisible(find.byType(TextField));
    await t.tap(find.byType(TextField));
    await _settle(t);
    final r = t.getRect(find.byType(TextField));
    expect(r.bottom <= 640 - 300 && r.top >= 0, isTrue, reason: '$r');
  });

  testWidgets('reduced motion: deck changes with a plain fade', (t) async {
    t.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await t.binding.setSurfaceSize(const Size(400, 850));
    final c = TopicsController();
    await t.pumpWidget(_app(c, const TopicsScreen()));
    await _settle(t);
    await t.tap(find.text('غيّرها'));
    await t.pump(const Duration(milliseconds: 200));
    expect(find.text('2 من 20'), findsOneWidget);
    expect(c.currentIndex, 1);
    await t.tap(find.byIcon(Icons.arrow_forward_rounded).first);
    await t.pump(const Duration(milliseconds: 200));
    expect(find.text('1 من 20'), findsOneWidget);
  });
}
