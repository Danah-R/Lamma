// Every kind of text in the app comes out in Thmanyah.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/l10n/app_localizations.dart';
import 'package:lamma/splash/lamma_splash.dart';
import 'package:lamma/theme.dart';

RenderParagraph? _para(RenderObject r) {
  if (r is RenderParagraph) return r;
  RenderParagraph? out;
  r.visitChildren((c) => out ??= _para(c));
  return out;
}

/// The family the first paragraph under [f] is painted with.
String? _family(WidgetTester t, Finder f) {
  final p = _para(f.evaluate().first.renderObject!);
  return p?.text.style?.fontFamily;
}

Widget _app(Widget home) => MaterialApp(
  theme: buildTheme(),
  locale: const Locale('ar'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  test('theme: family on the theme, all text themes, and the weights', () {
    final th = buildTheme();
    expect(th.textTheme.bodyMedium!.fontFamily, kFontFamily);
    expect(th.textTheme.headlineLarge!.fontFamily, kFontFamily);
    expect(th.textTheme.labelSmall!.fontFamily, kFontFamily);
    expect(th.primaryTextTheme.titleLarge!.fontFamily, kFontFamily);
    expect(th.appBarTheme.titleTextStyle!.fontFamily, kFontFamily);
    expect(th.snackBarTheme.contentTextStyle!.fontFamily, kFontFamily);
    expect(th.dialogTheme.titleTextStyle!.fontFamily, kFontFamily);
    expect(th.dialogTheme.contentTextStyle!.fontFamily, kFontFamily);
    expect(th.tooltipTheme.textStyle!.fontFamily, kFontFamily);
    expect(th.inputDecorationTheme.hintStyle!.fontFamily, kFontFamily);
    expect(th.datePickerTheme.dayStyle!.fontFamily, kFontFamily);
    expect(th.timePickerTheme.dialTextStyle!.fontFamily, kFontFamily);
    expect(kFontFamily, 'Thmanyah');
  });

  testWidgets('plain text, text field + hint, snackbar, dialog, sheet, '
      'tooltip, date picker', (t) async {
    await t.binding.setSurfaceSize(const Size(400, 900));
    late BuildContext ctx;
    await t.pumpWidget(
      _app(
        Scaffold(
          appBar: AppBar(title: const Text('عنوان')),
          body: Builder(
            builder: (c) {
              ctx = c;
              return Column(
                children: [
                  const Text('نص عادي 123 abc'),
                  const TextField(
                    decoration: InputDecoration(
                      hintText: 'تلميح الحقل',
                      labelText: 'عنوان الحقل',
                      helperText: 'مساعد',
                    ),
                  ),
                  const Tooltip(message: 'تلميح الأداة', child: Text('زر')),
                  const Text(
                    'عنوان ثقيل',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
    expect(_family(t, find.text('عنوان')), kFontFamily);
    expect(_family(t, find.text('نص عادي 123 abc')), kFontFamily);
    expect(_family(t, find.text('تلميح الحقل')), kFontFamily);
    expect(_family(t, find.text('عنوان الحقل')), kFontFamily);
    expect(_family(t, find.text('مساعد')), kFontFamily);
    // the tooltip
    await t.longPress(find.text('زر'));
    await t.pump(const Duration(seconds: 1));
    expect(_family(t, find.text('تلميح الأداة')), kFontFamily);
    // snackbar
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: const Text('رسالة'),
        action: SnackBarAction(label: 'إجراء', onPressed: () {}),
      ),
    );
    await t.pump(const Duration(milliseconds: 600));
    expect(_family(t, find.text('رسالة')), kFontFamily);
    expect(_family(t, find.text('إجراء')), kFontFamily);
    // dialog
    showDialog<void>(
      context: ctx,
      builder: (_) => const AlertDialog(
        title: Text('عنوان الحوار'),
        content: Text('محتوى الحوار'),
      ),
    );
    await t.pumpAndSettle();
    expect(_family(t, find.text('عنوان الحوار')), kFontFamily);
    expect(_family(t, find.text('محتوى الحوار')), kFontFamily);
    Navigator.of(ctx).pop();
    await t.pumpAndSettle();
    // bottom sheet
    showModalBottomSheet<void>(
      context: ctx,
      builder: (_) => const SizedBox(
        height: 100,
        child: Center(child: Text('محتوى الورقة')),
      ),
    );
    await t.pumpAndSettle();
    expect(_family(t, find.text('محتوى الورقة')), kFontFamily);
    Navigator.of(ctx).pop();
    await t.pumpAndSettle();
    // date picker
    showDatePicker(
      context: ctx,
      initialDate: DateTime(2025, 3, 10),
      firstDate: DateTime(2025),
      lastDate: DateTime(2026),
    );
    await t.pumpAndSettle();
    expect(_family(t, find.text('10')), kFontFamily);
    final anyDayLabel = find.byType(Dialog);
    expect(anyDayLabel, findsOneWidget);
    final texts = find.descendant(of: anyDayLabel, matching: find.byType(Text));
    for (final e in texts.evaluate()) {
      final f = _para(e.renderObject!)?.text.style?.fontFamily;
      expect(
        f,
        kFontFamily,
        reason: 'date picker text "${(e.widget as Text).data}"',
      );
    }
  });

  testWidgets('the splash screen is in Thmanyah too', (t) async {
    await t.binding.setSurfaceSize(const Size(400, 900));
    await t.pumpWidget(_app(LammaSplash(onStart: () {})));
    for (var i = 0; i < 40; i++) {
      await t.pump(const Duration(milliseconds: 250));
    }
    expect(find.text('لمّه'), findsOneWidget);
    expect(_family(t, find.text('لمّه')), kFontFamily);
    expect(_family(t, find.text('يلا نتلمّ')), kFontFamily);
    final style = t.widget<Text>(find.text('لمّه')).style!;
    expect(style.fontWeight, FontWeight.w900); // the one Black text
  });

  test('source scan: painters, families, Cupertino, weights', () {
    final files = [
      for (final f in Directory('lib').listSync(recursive: true))
        if (f is File && f.path.endsWith('.dart') && !f.path.contains('/l10n/'))
          f,
    ];
    final problems = <String>[];
    for (final f in files) {
      final src = f.readAsStringSync();
      // 1) a TextPainter paints outside the theme: it must name the family
      for (final m in RegExp(r'TextPainter\(').allMatches(src)) {
        final chunk = src.substring(
          m.start,
          (m.start + 500).clamp(0, src.length),
        );
        if (!chunk.contains('fontFamily: kFontFamily')) {
          problems.add('${f.path}: TextPainter without kFontFamily');
        }
      }
      // 2) no other family
      for (final m in RegExp(r'fontFamily:\s*([^,\n)]+)').allMatches(src)) {
        final v = m.group(1)!.trim();
        if (v != 'kFontFamily' &&
            !v.startsWith('DefaultTextStyle.of(') &&
            v != 'fontFamily') {
          problems.add('${f.path}: fontFamily: $v');
        }
      }
      // 3) no Cupertino widgets (the localizations delegate is fine)
      for (final m in RegExp(
        r'Cupertino(App|Theme|[A-Z]\w+)\(',
      ).allMatches(src)) {
        problems.add('${f.path}: ${m.group(0)}');
      }
      // 4) no other font source, and no weights that would pick Black
      if (src.contains('GoogleFonts') || src.contains('google_fonts')) {
        problems.add('${f.path}: google_fonts');
      }
      // w800 would pick Black, so everything is w700 ... except the splash
      // logo, which is Black (w900) as designed
      final isSplash = f.path.endsWith('splash/lamma_splash.dart');
      if (src.contains('FontWeight.w800')) problems.add('${f.path}: w800');
      if (src.contains('FontWeight.w900') && !isSplash) {
        problems.add('${f.path}: w900');
      }
      if (isSplash) {
        final n = 'FontWeight.w900'.allMatches(src).length;
        if (n != 1)
          problems.add('${f.path}: expected exactly one w900, got $n');
      }
    }
    expect(problems, isEmpty);
  });
}
