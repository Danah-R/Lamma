// Single source of truth for the "moments of our day" feed. Separate from
// the family chat: nothing here knows about chat.

import 'package:flutter/material.dart';

import '../../data/family_members.dart';
import '../notifications/notification_events.dart';
import '../notifications/notifications_controller.dart';

/// A family member as the moments feed shows them.
typedef MomentsMember = FamilyMember;

const momentsMeId = familyMeId;

const momentsMembers = familyMembers;

MomentsMember momentsMember(String id) => familyMemberById(id);

/// Placeholder pictures for the sample data, until real photos are wired.
enum MomentScene { park, coffee, dinner, desert }

class MomentComment {
  final String authorId, text;
  final DateTime createdAt;
  const MomentComment({
    required this.authorId,
    required this.text,
    required this.createdAt,
  });
}

class Moment {
  final int id;
  final String authorId, caption;

  /// Local file path of a real photo; when null, [scene] is drawn instead.
  final String? imagePath;
  final MomentScene scene;
  final List<String> withIds;
  final DateTime createdAt;
  final List<String> likedBy;
  final List<MomentComment> comments;

  /// Posted by me in this session ("جديد" badge + highlighted frame).
  final bool isNew;

  const Moment({
    required this.id,
    required this.authorId,
    required this.caption,
    required this.createdAt,
    this.imagePath,
    this.scene = MomentScene.park,
    this.withIds = const [],
    this.likedBy = const [],
    this.comments = const [],
    this.isNew = false,
  });

  Moment copyWith({List<String>? likedBy, List<MomentComment>? comments}) =>
      Moment(
        id: id,
        authorId: authorId,
        caption: caption,
        createdAt: createdAt,
        imagePath: imagePath,
        scene: scene,
        withIds: withIds,
        likedBy: likedBy ?? this.likedBy,
        comments: comments ?? this.comments,
        isNew: isNew,
      );
}

class MomentsController extends ChangeNotifier {
  final DateTime Function() _clock;
  final NotificationsController? _notifications;
  late final List<Moment> _moments;
  int _nextId = 100;

  MomentsController({DateTime Function()? clock, this._notifications})
    : _clock = clock ?? DateTime.now {
    _moments = _seed();
  }

  Moment? byId(int id) {
    for (final m in _moments) {
      if (m.id == id) return m;
    }
    return null;
  }

  List<Moment> get moments => List.unmodifiable(_moments);

  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Set<String> get _todayAuthors => {
    for (final m in _moments)
      if (sameDay(m.createdAt, _clock())) m.authorId,
  };

  int get sharedTodayCount => _todayAuthors.length;
  bool get didIShareToday => _todayAuthors.contains(momentsMeId);

  bool isLiked(Moment m) => m.likedBy.contains(momentsMeId);

  void toggleLike(int id) {
    _replace(id, (m) {
      final liked = m.likedBy.contains(momentsMeId);
      return m.copyWith(
        likedBy: liked
            ? [
                for (final x in m.likedBy)
                  if (x != momentsMeId) x,
              ]
            : [...m.likedBy, momentsMeId],
      );
    });
  }

  /// [authorId] defaults to me; a comment by someone else notifies me.
  void addComment(int id, String text, {String authorId = momentsMeId}) {
    final t = text.trim();
    if (t.isEmpty) return;
    final now = _clock();
    _replace(
      id,
      (m) => m.copyWith(
        comments: [
          ...m.comments,
          MomentComment(authorId: authorId, text: t, createdAt: now),
        ],
      ),
    );
    final m = byId(id);
    if (m != null) {
      _notifications?.add(
        NotificationEvents.momentComment(
          momentId: id,
          commentIndex: m.comments.length - 1,
          momentOwnerId: m.authorId,
          authorId: authorId,
          text: t,
          at: now,
          imagePath: m.imagePath,
          scene: m.scene.name,
        ),
      );
    }
  }

  /// [authorId] defaults to me; a moment by someone else notifies me.
  void addMoment({
    required String caption,
    String? imagePath,
    MomentScene scene = MomentScene.park,
    List<String> withIds = const [],
    String authorId = momentsMeId,
  }) {
    final mine = authorId == momentsMeId;
    final moment = Moment(
      id: _nextId++,
      authorId: authorId,
      caption: caption.trim(),
      imagePath: imagePath,
      scene: scene,
      withIds: withIds,
      createdAt: _clock(),
      isNew: mine,
    );
    _moments.insert(0, moment);
    notifyListeners();
    _notifications?.add(
      NotificationEvents.momentShared(
        momentId: moment.id,
        authorId: authorId,
        caption: moment.caption,
        at: moment.createdAt,
        imagePath: imagePath,
        scene: scene.name,
      ),
    );
  }

  void _replace(int id, Moment Function(Moment) f) {
    final i = _moments.indexWhere((m) => m.id == id);
    if (i < 0) return;
    _moments[i] = f(_moments[i]);
    notifyListeners();
  }

  List<Moment> _seed() {
    final now = _clock();
    DateTime at(int daysAgo, int h, int m) =>
        DateTime(now.year, now.month, now.day - daysAgo, h, m);
    MomentComment c(String by, String text, DateTime t) =>
        MomentComment(authorId: by, text: text, createdAt: t);
    return [
      Moment(
        id: 2,
        authorId: 'sa',
        scene: MomentScene.park,
        caption: 'أول مشي بالحديقة بعد الصيف، الجو خيال',
        withIds: const ['am'],
        createdAt: at(0, 16, 10),
        likedBy: const ['am', 'yo', 'no', 'ab'],
        comments: [
          c('am', 'كانت أحلى مشية!', at(0, 16, 20)),
          c('yo', 'المرة الجاية خذوني', at(0, 16, 25)),
        ],
      ),
      Moment(
        id: 3,
        authorId: 'yo',
        scene: MomentScene.dinner,
        caption: 'كبسة جدتي اليوم، ما فيه مثلها',
        createdAt: at(0, 13, 30),
        likedBy: const ['sa', 'am', 'no', 'ab', 'mo'],
        comments: [
          c('no', 'خلّوا لي صحن!', at(0, 13, 40)),
          c('sa', 'جدتي أسطورة', at(0, 13, 45)),
          c('ab', 'وش السر في الكبسة؟', at(0, 14, 0)),
        ],
      ),
      Moment(
        id: 1,
        authorId: 'am',
        scene: MomentScene.coffee,
        caption: 'قهوة الصبح مع أمي، مين بيجينا العصر؟',
        createdAt: at(0, 8, 15),
        likedBy: const ['sa', 'yo', 'mo'],
        comments: [
          c('sa', 'أنا جاية بعد الدوام', at(0, 8, 30)),
          c('yo', 'خلّوا لي فنجال!', at(0, 8, 35)),
          c('ab', 'الدلة هذي حقت جدي؟', at(0, 9, 0)),
          c('am', 'إيه نفسها', at(0, 9, 5)),
        ],
      ),
      Moment(
        id: 4,
        authorId: 'ab',
        scene: MomentScene.desert,
        caption: 'طلعة البر مع الشباب',
        createdAt: at(1, 18, 40),
        likedBy: const ['mo', 'yo'],
        comments: [c('mo', 'وين المكان؟', at(1, 19, 0))],
      ),
    ];
  }
}
