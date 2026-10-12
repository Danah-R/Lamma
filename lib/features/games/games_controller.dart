// Starting a family game invites the others; recorded in the notifications
// log as my own (already read) act.

import 'package:flutter/foundation.dart';

import '../../data/family_members.dart';
import '../notifications/notification_events.dart';
import '../notifications/notifications_controller.dart';

class GamesController extends ChangeNotifier {
  final NotificationsController? _notifications;
  String? _lastStarted;

  GamesController({this._notifications});

  String? get lastStarted => _lastStarted;

  /// Sends "يبيكم تلعبون [game] الليلة" in my name.
  void start(String gameTitle) {
    _lastStarted = gameTitle;
    notifyListeners();
    _notifications?.logOwn(
      NotificationEvents.gameInvite(
        actorId: familyMeId,
        game: gameTitle,
        at: DateTime.now(),
        includeMe: true,
      ),
    );
  }
}
