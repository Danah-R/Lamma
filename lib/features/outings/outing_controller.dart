// Weekend-outing votes and suggestions. What I do here is recorded in the
// notifications log (already read: it is my own act, so no badge, no banner).

import 'package:flutter/foundation.dart';

import '../../data/family_members.dart';
import '../notifications/notification_events.dart';
import '../notifications/notifications_controller.dart';

class OutingController extends ChangeNotifier {
  final NotificationsController? _notifications;
  final Set<int> _myVotes = {};

  OutingController({this._notifications});

  bool hasVoted(int placeIndex) => _myVotes.contains(placeIndex);

  /// Vote for a place, or take the vote back. Only a new vote is announced.
  void toggleVote(int placeIndex) {
    if (_myVotes.remove(placeIndex)) {
      notifyListeners();
      return;
    }
    _myVotes.add(placeIndex);
    notifyListeners();
    _notifications?.logOwn(
      NotificationEvents.outingVote(
        actorId: familyMeId,
        at: DateTime.now(),
        includeMe: true,
      ),
    );
  }

  /// Suggest a place for the weekend outing.
  void suggest(String place) {
    final p = place.trim();
    if (p.isEmpty) return;
    _notifications?.logOwn(
      NotificationEvents.outingSuggested(
        actorId: familyMeId,
        place: p,
        at: DateTime.now(),
        includeMe: true,
      ),
    );
  }
}
