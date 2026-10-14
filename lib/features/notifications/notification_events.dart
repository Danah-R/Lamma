// Builds a notification from an event's own data. The sentence is composed
// here (with verbs that agree with the person's gender), never hard-coded
// per screen. Everything returns null for acts by me.

import '../../data/family_members.dart';
import 'notification_model.dart';

class NotificationEvents {
  const NotificationEvents._();

  static String _verb(Gender g, String male, String female) =>
      g == Gender.female ? female : male;

  /// [includeMe]: build it even when the actor is me (for the log of my own
  /// acts); otherwise acts by me produce nothing.
  static NotificationActor? _actor(String id, [bool includeMe = false]) {
    if (id == notificationMeId && !includeMe) return null;
    return notificationActors[id];
  }

  static String _clip(String s, [int max = 40]) {
    final t = s.trim();
    final chars = t.runes.toList();
    return chars.length <= max
        ? t
        : '${String.fromCharCodes(chars.take(max))}…';
  }

  /// "سارة شاركت لحظة: …"
  static AppNotification? momentShared({
    required int momentId,
    required String authorId,
    required String caption,
    required DateTime at,
    String? imagePath,
    String? scene,
  }) {
    final a = _actor(authorId);
    if (a == null) return null;
    final v = _verb(a.gender, 'شارك', 'شاركت');
    return AppNotification(
      id: 'moment-$momentId',
      type: NotificationType.moment,
      actorId: a.id,
      lead: a.name,
      text: '${a.name} $v لحظة: $caption',
      thumbnail: NotificationThumb(imagePath: imagePath, scene: scene),
      targetRoute: NotificationRoute.moments,
      targetId: '$momentId',
      createdAt: at,
    );
  }

  /// "يوسف علّق على لحظة سارة: …" / "… على لحظتك: …"
  static AppNotification? momentComment({
    required int momentId,
    required int commentIndex,
    required String momentOwnerId,
    required String authorId,
    required String text,
    required DateTime at,
    String? imagePath,
    String? scene,
  }) {
    final a = _actor(authorId);
    if (a == null) return null;
    final v = _verb(a.gender, 'علّق', 'علّقت');
    final onMine = momentOwnerId == notificationMeId;
    final owner = notificationActors[momentOwnerId]?.name ?? '';
    final target = onMine ? 'لحظتك' : 'لحظة $owner';
    return AppNotification(
      id: 'comment-$momentId-$commentIndex',
      type: NotificationType.comment,
      actorId: a.id,
      lead: a.name,
      text: '${a.name} $v على $target: $text',
      thumbnail: NotificationThumb(imagePath: imagePath, scene: scene),
      targetRoute: NotificationRoute.moments,
      targetId: '$momentId',
      createdAt: at,
    );
  }

  /// "أمينة في المحادثة: …" (first 40 characters)
  static AppNotification? chatMessage({
    required int messageId,
    required String authorId,
    required String text,
    required DateTime at,
  }) {
    final a = _actor(authorId);
    if (a == null) return null;
    return AppNotification(
      id: 'chat-$messageId',
      type: NotificationType.chat,
      actorId: a.id,
      lead: a.name,
      text: '${a.name} في المحادثة: ${_clip(text)}',
      targetRoute: NotificationRoute.chat,
      targetId: '$messageId',
      createdAt: at,
    );
  }

  /// "يوسف اقترح طلعة الويكند: وادي حنيفة"
  static AppNotification? outingSuggested({
    required String actorId,
    required String place,
    required DateTime at,
    bool includeMe = false,
  }) {
    final a = _actor(actorId, includeMe);
    if (a == null) return null;
    final v = _verb(a.gender, 'اقترح', 'اقترحت');
    return AppNotification(
      id: 'event-${a.id}-${at.millisecondsSinceEpoch}',
      type: NotificationType.event,
      actorId: a.id,
      lead: a.name,
      text: '${a.name} $v طلعة الويكند: $place',
      targetRoute: NotificationRoute.activities,
      targetId: 'weekend-outing',
      createdAt: at,
    );
  }

  /// "نورة صوّتت على طلعة الويكند"
  static AppNotification? outingVote({
    required String actorId,
    required DateTime at,
    bool includeMe = false,
  }) {
    final a = _actor(actorId, includeMe);
    if (a == null) return null;
    final v = _verb(a.gender, 'صوّت', 'صوّتت');
    return AppNotification(
      id: 'vote-${a.id}-${at.millisecondsSinceEpoch}',
      type: NotificationType.vote,
      actorId: a.id,
      lead: a.name,
      text: '${a.name} $v على طلعة الويكند',
      targetRoute: NotificationRoute.activities,
      targetId: 'weekend-outing',
      createdAt: at,
    );
  }

  /// "عبدالله يبيكم تلعبون ولا كلمة الليلة"
  static AppNotification? gameInvite({
    required String actorId,
    required String game,
    required DateTime at,
    bool includeMe = false,
  }) {
    final a = _actor(actorId, includeMe);
    if (a == null) return null;
    return AppNotification(
      id: 'game-${a.id}-${at.millisecondsSinceEpoch}',
      type: NotificationType.game,
      actorId: a.id,
      lead: a.name,
      text: '${a.name} يبيكم تلعبون $game الليلة',
      targetRoute: NotificationRoute.games,
      createdAt: at,
    );
  }

  /// "نادي الكتاب: باقي 5 أيام على نقاش العادات الذرية"
  static AppNotification clubReminder({
    required String bookTitle,
    required int daysLeft,
    required DateTime at,
  }) {
    final days = switch (daysLeft) {
      1 => 'يوم',
      2 => 'يومين',
      _ => '$daysLeft أيام',
    };
    return AppNotification(
      id: 'club-$bookTitle-$daysLeft',
      type: NotificationType.club,
      lead: 'نادي الكتاب:',
      text: 'نادي الكتاب: باقي $days على نقاش $bookTitle',
      targetRoute: NotificationRoute.clubs,
      createdAt: at,
    );
  }

  /// "استبيان الشهر جاهز: كيف كان شهرك مع العيلة؟" (opens the profile, where the survey is)
  static AppNotification monthlySurvey({
    required String month,
    required DateTime at,
  }) => AppNotification(
    id: 'survey-$month',
    type: NotificationType.survey,
    lead: 'استبيان الشهر:',
    text: 'استبيان الشهر جاهز: كيف كان شهرك مع العيلة؟',
    targetRoute: NotificationRoute.profile,
    createdAt: at,
  );
}
