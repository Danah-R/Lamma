// State of the family chat tab. Text only: no photos, no moments.

import 'package:flutter/material.dart';

import '../../data/family_members.dart';
import '../notifications/notification_events.dart';
import '../notifications/notifications_controller.dart';

typedef ChatMember = FamilyMember;

const chatMeId = familyMeId;

const chatMembers = familyMembers;

ChatMember chatMember(String id) => familyMemberById(id);

enum ChatKind { text, reply, poll }

class ChatMessage {
  final int id;
  final ChatKind kind;
  final String authorId, text;

  /// For [ChatKind.reply]: the question being answered.
  final String? quote;
  final DateTime createdAt;
  const ChatMessage({
    required this.id,
    required this.kind,
    required this.authorId,
    required this.text,
    required this.createdAt,
    this.quote,
  });
}

class PollOption {
  final String id, label;
  final int baseVotes;
  const PollOption(this.id, this.label, this.baseVotes);
}

const dailyQuestion = 'وش أحلى شي صار لك هالأسبوع؟';
const _pollOptions = [
  PollOption('kabsa', 'كبسة', 2),
  PollOption('burger', 'برجر', 1),
  PollOption('grill', 'مشويات', 2),
];

class FamilyChatController extends ChangeNotifier {
  final DateTime Function() _clock;
  final List<ChatMessage> _messages;
  int _nextId = 100;

  String? _myVote;
  bool _answered = false;
  bool _replyingToQuestion = false;

  final NotificationsController? _notifications;

  FamilyChatController({DateTime Function()? clock, this._notifications})
    : _clock = clock ?? DateTime.now,
      _messages = [] {
    _messages.addAll(_seed());
  }

  DateTime get now => _clock();

  /// Oldest first.
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  int get onlineCount => 3;
  String get question => dailyQuestion;

  /// "عبدالله يكتب" indicator.
  ChatMember get typing => chatMember('ab');

  bool get answered => _answered;
  bool get replyingToQuestion => _replyingToQuestion;

  List<PollOption> get pollOptions => _pollOptions;
  String? get myVote => _myVote;
  int votesFor(PollOption o) => o.baseVotes + (_myVote == o.id ? 1 : 0);
  int get totalVotes =>
      _pollOptions.fold(0, (sum, o) => sum + o.baseVotes) +
      (_myVote == null ? 0 : 1);

  /// One vote per person; tapping the chosen option again takes it back.
  void vote(String optionId) {
    _myVote = _myVote == optionId ? null : optionId;
    notifyListeners();
  }

  /// "جاوب": the next message is an answer to the daily question.
  void replyToQuestion() {
    _replyingToQuestion = true;
    notifyListeners();
  }

  void cancelReply() {
    if (!_replyingToQuestion) return;
    _replyingToQuestion = false;
    notifyListeners();
  }

  void send(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    final reply = _replyingToQuestion;
    _messages.add(
      ChatMessage(
        id: _nextId++,
        kind: reply ? ChatKind.reply : ChatKind.text,
        authorId: chatMeId,
        text: t,
        quote: reply ? dailyQuestion : null,
        createdAt: _clock(),
      ),
    );
    if (reply) {
      _answered = true;
      _replyingToQuestion = false;
    }
    notifyListeners();
  }

  /// A message from someone else arrives: it joins the chat and notifies me.
  void receive(String authorId, String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    final m = ChatMessage(
      id: _nextId++,
      kind: ChatKind.text,
      authorId: authorId,
      text: t,
      createdAt: _clock(),
    );
    _messages.add(m);
    notifyListeners();
    _notifications?.add(
      NotificationEvents.chatMessage(
        messageId: m.id,
        authorId: authorId,
        text: t,
        at: m.createdAt,
      ),
    );
  }

  ChatMessage? messageById(int id) {
    for (final m in _messages) {
      if (m.id == id) return m;
    }
    return null;
  }

  List<ChatMessage> _seed() {
    final n = _clock();
    DateTime at(int h, int m) => DateTime(n.year, n.month, n.day, h, m);
    ChatMessage t(int id, String by, String text, DateTime when) => ChatMessage(
      id: id,
      kind: ChatKind.text,
      authorId: by,
      text: text,
      createdAt: when,
    );
    return [
      t(3, 'am', 'القهوة جاهزة، مين بيجينا العصر؟', at(8, 15)),
      t(4, 'sa', 'أنا جاية بعد الدوام', at(8, 20)),
      t(5, 'yo', 'خلّوا لي فنجال!', at(8, 31)),
      t(6, 'ab', 'وأنا بجيب معي تمر', at(9, 2)),
      ChatMessage(
        id: 7,
        kind: ChatKind.poll,
        authorId: 'sa',
        text: 'وش تبون تاكلون يوم الخميس؟',
        createdAt: at(16, 25),
      ),
      t(8, chatMeId, 'مشويات أكيد', at(16, 40)),
    ];
  }
}
