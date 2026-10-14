import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../backend/backend.dart';
import '../../data.dart' as app;
import '../notifications/notification_events.dart';
import '../notifications/notifications_controller.dart';
import 'survey_model.dart';

/// The monthly survey: it is due from the start of each month until the person answers it, and the
/// first time the app opens in a new month it sends a notification. Whether it was answered is kept on
/// the phone and, with the family connected, in the database (so a new phone knows too).
class SurveyController extends ChangeNotifier {
  final NotificationsController? _notifications;
  final DateTime Function() _clock;
  SurveyController({
    NotificationsController? notifications,
    DateTime Function()? clock,
  }) : _notifications = notifications,
       _clock = clock ?? DateTime.now;

  static const _doneKey = 'survey_done_month';
  static const _notifiedKey = 'survey_notified_month';

  String get month => surveyMonthKey(_clock());
  bool _done = false;

  /// True once this month's survey is answered.
  bool get done => _done;

  /// True while this month's survey is waiting for an answer (it shows on the profile).
  bool get due => !_done;

  /// Looks at what was answered before and announces a new month's survey once.
  Future<void> init({bool announce = true}) async {
    String? doneMonth, notifiedMonth;
    try {
      final prefs = await SharedPreferences.getInstance();
      doneMonth = prefs.getString(_doneKey);
      notifiedMonth = prefs.getString(_notifiedKey);
    } catch (_) {}
    _done = doneMonth == month;
    if (!_done && app.sharedLive && await Backend.surveyAnswered(month)) {
      _done = true;
      _remember(_doneKey, month);
    }
    if (!_done && announce && notifiedMonth != month) {
      _notifications?.add(
        NotificationEvents.monthlySurvey(month: month, at: _clock()),
      );
      _remember(_notifiedKey, month);
    }
    notifyListeners();
  }

  Future<void> _remember(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (_) {}
  }

  /// Saves the answers (for the family's database when connected) and marks the month as done.
  Future<void> submit(SurveyAnswers answers) async {
    _done = true;
    notifyListeners();
    await _remember(_doneKey, month);
    if (app.sharedLive) await Backend.submitSurvey(month, answers.toJson());
  }
}
