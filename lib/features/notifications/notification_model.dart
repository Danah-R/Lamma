import 'package:flutter/material.dart';

import '../games/shared/family_players.dart';

enum NotificationType { moment, comment, chat, event, game, club, vote }

/// Where tapping a notification goes.
enum NotificationRoute { moments, chat, activities, games, clubs }

/// A small picture for the notification (a moment's photo). Either a real
/// file, or the sample scene's name until real photos are wired.
class NotificationThumb {
  final String? imagePath;
  final String? scene;
  const NotificationThumb({this.imagePath, this.scene});
}

class AppNotification {
  final String id;
  final NotificationType type;

  /// Who did it; null for the system (e.g. the book club reminder).
  final String? actorId;

  /// The bold lead of [text] ("يوسف" / "نادي الكتاب:"), for the UI.
  final String lead;

  /// The whole sentence, built from the event's own data.
  final String text;
  final NotificationThumb? thumbnail;
  final NotificationRoute targetRoute;
  final String? targetId;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.type,
    required this.text,
    required this.targetRoute,
    required this.createdAt,
    this.actorId,
    this.lead = '',
    this.thumbnail,
    this.targetId,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    type: type,
    actorId: actorId,
    lead: lead,
    text: text,
    thumbnail: thumbnail,
    targetRoute: targetRoute,
    targetId: targetId,
    createdAt: createdAt,
    isRead: isRead ?? this.isRead,
  );
}

/// The id notifications use for "me": nothing is announced about my own acts.
const notificationMeId = 'mo';

class NotificationActor {
  final String id, name, initial;
  final Color color, ink;
  final Gender gender;
  const NotificationActor(
    this.id,
    this.name,
    this.initial,
    this.color,
    this.ink,
    this.gender,
  );
}

// Same ids as the moments and chat members. Gender comes from
// [familyPlayers] (via [genderOfName]).
final notificationActors = <String, NotificationActor>{
  for (final a in [
    ('mo', 'محمد', 'م', const Color(0xFF9A4A3E), const Color(0xFFFFFFFF)),
    ('sa', 'سارة', 'س', const Color(0xFF1E2A47), const Color(0xFFFFFFFF)),
    ('am', 'أمينة', 'أ', const Color(0xFF3E7A75), const Color(0xFFFFFFFF)),
    ('ab', 'عبدالله', 'ع', const Color(0xFF8FA580), const Color(0xFF2B211E)),
    ('no', 'نورة', 'ن', const Color(0xFFDEB461), const Color(0xFF2B211E)),
    ('yo', 'يوسف', 'ي', const Color(0xFFE29079), const Color(0xFF2B211E)),
  ])
    a.$1: NotificationActor(a.$1, a.$2, a.$3, a.$4, a.$5, genderOfName(a.$2)),
};
