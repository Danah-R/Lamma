import '../../data/family_members.dart';

enum NotificationType { moment, comment, chat, event, game, club, vote, survey }

/// Where tapping a notification goes.
enum NotificationRoute { moments, chat, activities, games, clubs, profile }

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
const notificationMeId = familyMeId;

/// Who a notification is from: the shared family list.
typedef NotificationActor = FamilyMember;

Map<String, NotificationActor> get notificationActors => {
  for (final m in familyMembers) m.id: m,
};
