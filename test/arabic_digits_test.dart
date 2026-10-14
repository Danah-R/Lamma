import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/number_symbols_data.dart' show numberFormatSymbols;
import 'package:lamma/l10n/app_localizations.dart';

void main() {
  test('points read as 10 نقاط and 11 نقطة with the digits 0-9', () async {
    numberFormatSymbols['ar'] = numberFormatSymbols['en']!;
    final l = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(l.pointsEarned(10), '+10 نقاط');
    expect(l.pointsEarned(11), '+11 نقطة');
  });
}
