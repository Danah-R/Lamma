// Starting notifications for the demo. They go through the same event
// builders as live events, from the data the screens already hold.

import 'dart:async';

import '../clubs/clubs_controller.dart';
import '../family_chat/family_chat_controller.dart';
import '../moments/moments_controller.dart';
import 'notification_events.dart';
import 'notifications_controller.dart';

void seedNotifications({
  required NotificationsController notifications,
  required MomentsController moments,
  required FamilyChatController chat,
  required ClubsController clubs,
  DateTime? now,
}) {
  final t = now ?? DateTime.now();
  DateTime ago(Duration d) => t.subtract(d);
  DateTime yesterday(int h, int m) =>
      DateTime(t.year, t.month, t.day - 1, h, m);
  void history(dynamic n, {required bool read}) {
    if (n == null) return;
    notifications.add(n.copyWith(isRead: read), announce: false);
  }

  // Sarah's moment, and Yousef's comment on it: unread
  final sarah = moments.byId(2);
  if (sarah != null) {
    history(
      NotificationEvents.momentShared(
        momentId: sarah.id,
        authorId: sarah.authorId,
        caption: sarah.caption,
        at: ago(const Duration(minutes: 5)),
        imagePath: sarah.imagePath,
        scene: sarah.scene.name,
      ),
      read: false,
    );
    final i = sarah.comments.indexWhere((c) => c.authorId == 'yo');
    if (i >= 0) {
      history(
        NotificationEvents.momentComment(
          momentId: sarah.id,
          commentIndex: i,
          momentOwnerId: sarah.authorId,
          authorId: 'yo',
          text: sarah.comments[i].text,
          at: ago(const Duration(minutes: 20)),
          imagePath: sarah.imagePath,
          scene: sarah.scene.name,
        ),
        read: false,
      );
    }
  }

  // Amina's chat message
  final amina = chat.messageById(3);
  if (amina != null) {
    final soon = ago(const Duration(minutes: 30));
    history(
      NotificationEvents.chatMessage(
        messageId: amina.id,
        authorId: amina.authorId,
        text: amina.text,
        at: amina.createdAt.isAfter(soon) ? soon : amina.createdAt,
      ),
      read: true,
    );
  }

  // yesterday
  history(
    NotificationEvents.gameInvite(
      actorId: 'ab',
      game: 'ولا كلمة',
      at: yesterday(19, 10),
    ),
    read: true,
  );
  clubs.announceDiscussionReminder(at: yesterday(20, 0), announce: false);
  notifications.markRead(
    notifications.items.firstWhere((n) => n.id.startsWith('club-')).id,
  );
  history(
    NotificationEvents.outingVote(actorId: 'no', at: yesterday(17, 40)),
    read: true,
  );
}

/// [kDemoNotifications]: 3.5 seconds after launch, Yousef suggests a weekend
/// outing, so the banner can be seen.
Timer scheduleDemoNotification(NotificationsController notifications) =>
    Timer(const Duration(milliseconds: 3500), () {
      notifications.add(
        NotificationEvents.outingSuggested(
          actorId: 'yo',
          place: 'وادي حنيفة',
          at: DateTime.now(),
        ),
      );
    });
