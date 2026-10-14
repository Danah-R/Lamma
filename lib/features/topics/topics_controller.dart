// Single source of truth for the "talk topics" feature. The Topics screen
// and the "tonight's topic" card on the Activities page both read (and
// write) through this controller, so saving/discussing in one place shows
// in the other.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../backend/backend.dart';
import '../../data.dart' as app;
import 'topics_data.dart';

class TopicsController extends ChangeNotifier {
  TopicsController() {
    app.sharedTick.addListener(
      notifyListeners,
    ); // someone in the family added or talked about a topic
  }

  @override
  void dispose() {
    app.sharedTick.removeListener(notifyListeners);
    super.dispose();
  }

  /// Everyone's topics. With the family connected they come from the database, so what anyone adds
  /// shows up for everyone; otherwise they are the ones saved on this phone.
  List<Topic> get _family => app.sharedLive
      ? [
          for (final t in app.sharedTopics)
            Topic(
              id: 't${t.id}',
              categoryId: mineCategoryId,
              text: t.text,
              isMine: t.authorId != null && t.authorId == app.profile.memberId,
            ),
        ]
      : _myTopics;

  bool _sharedDone(String id) =>
      app.sharedLive &&
      app.sharedTopics.any((t) => 't${t.id}' == id && t.discussed);
  final List<Topic> _myTopics = [];
  final Set<String> _savedIds = {};
  final List<String> _discussedIds = []; // newest first

  /// null = all categories.
  String? _selectedCategory;
  int _currentIndex = 0;

  String? get selectedCategory => _selectedCategory;
  int get currentIndex => _currentIndex;
  List<Topic> get myTopics => List.unmodifiable(_family);
  Set<String> get savedIds => Set.unmodifiable(_savedIds);
  List<String> get discussedIds => List.unmodifiable(_discussedIds);

  List<Topic> get allTopics => [...baseTopics, ..._family];

  /// Categories to show in the filter bar ("مواضيعنا" only once it has any).
  List<TopicCategory> get categories => [
    for (final c in topicCategories)
      if (c.id != mineCategoryId || _family.isNotEmpty) c,
  ];

  TopicCategory category(String id) =>
      topicCategories.firstWhere((c) => c.id == id);

  /// The deck: topics of the selected category (or all of them).
  List<Topic> get visibleTopics => [
    for (final t in allTopics)
      if (_selectedCategory == null || t.categoryId == _selectedCategory) t,
  ];

  /// Topics nobody has talked about yet (newest first), by anyone in the family.
  List<Topic> get pendingFamilyTopics => [
    for (final t in _family.reversed)
      if (!isDiscussed(t.id)) t,
  ];

  /// The ones I added that are still waiting (shown on my profile).
  List<Topic> get myPendingTopics => [
    for (final t in pendingFamilyTopics)
      if (t.isMine) t,
  ];

  /// Topics for the "tonight" card on the Activities page: what the family wants to talk about, then the usual.
  List<Topic> get tonightTopics => [
    ...pendingFamilyTopics,
    for (final id in tonightTopicIds) allTopics.firstWhere((t) => t.id == id),
  ];

  List<Topic> get trendingTopics => [
    for (final id in trendingTopicIds) allTopics.firstWhere((t) => t.id == id),
  ];

  Topic? byId(String id) {
    for (final t in allTopics) {
      if (t.id == id) return t;
    }
    return null;
  }

  bool isSaved(String id) => _savedIds.contains(id);
  bool isDiscussed(String id) => _discussedIds.contains(id) || _sharedDone(id);

  void selectCategory(String? id) {
    if (id == _selectedCategory) return;
    _selectedCategory = id;
    _currentIndex = 0;
    notifyListeners();
  }

  void next() => _move(1);
  void prev() => _move(-1);

  void _move(int d) {
    final n = visibleTopics.length;
    if (n == 0) return;
    _currentIndex = ((_currentIndex + d) % n + n) % n;
    notifyListeners();
  }

  void toggleSave(String id) {
    if (!_savedIds.remove(id)) _savedIds.add(id);
    notifyListeners();
  }

  void markDiscussed(String id) {
    if (isDiscussed(id)) return;
    _discussedIds.insert(0, id);
    if (app.sharedLive && id.startsWith('t'))
      Backend.topicDiscussed(id.substring(1));
    app.claimFirst('topic:$id', app.profile.name);
    notifyListeners();
    _save();
  }

  /// Adds a topic of mine. [select] jumps the topics deck to it (what the topics screen wants);
  /// the Home page adds quietly without moving the deck.
  void addMyTopic(String text, {bool select = true}) {
    final v = text.trim();
    if (v.isEmpty) return;
    if (app.sharedLive) {
      // shown straight away, then replaced by the database's copy (which everyone sees)
      app.sharedTopics = [
        ...app.sharedTopics,
        app.FamilyTopic(
          'tmp${app.sharedTopics.length}',
          v,
          app.profile.memberId,
          false,
        ),
      ];
      Backend.addTopic(v);
    } else {
      _myTopics.add(
        Topic(
          id: 'm${_myTopics.length}',
          categoryId: mineCategoryId,
          text: v,
          isMine: true,
        ),
      );
    }
    if (select) {
      _selectedCategory = mineCategoryId;
      _currentIndex = _family.length - 1;
    }
    notifyListeners();
    _save();
  }

  // ---- remembered on the phone, so my topics survive a restart

  static const _prefsKey = 'my_topics';

  /// Loads the topics saved on this phone (call once at start).
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final list = List<Map<String, dynamic>>.from(jsonDecode(raw) as List);
      _myTopics.clear();
      for (final e in list) {
        final id = 'm${_myTopics.length}';
        _myTopics.add(
          Topic(
            id: id,
            categoryId: mineCategoryId,
            text: e['text'] as String,
            isMine: true,
          ),
        );
        if (e['discussed'] == true && !_discussedIds.contains(id))
          _discussedIds.add(id);
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode([
          for (final t in _myTopics)
            {'text': t.text, 'discussed': _discussedIds.contains(t.id)},
        ]),
      );
    } catch (_) {}
  }

  /// Puts the deck on [id]: selects its category and moves to it.
  void openTopic(String id) {
    final t = byId(id);
    if (t == null) return;
    _selectedCategory = t.categoryId;
    _currentIndex = visibleTopics.indexWhere((x) => x.id == id);
    notifyListeners();
  }
}
