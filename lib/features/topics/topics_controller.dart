// Single source of truth for the "talk topics" feature. The Topics screen
// and the "tonight's topic" card on the Activities page both read (and
// write) through this controller, so saving/discussing in one place shows
// in the other.

import 'package:flutter/foundation.dart';

import 'topics_data.dart';

class TopicsController extends ChangeNotifier {
  final List<Topic> _myTopics = [];
  final Set<String> _savedIds = {};
  final List<String> _discussedIds = []; // newest first

  /// null = all categories.
  String? _selectedCategory;
  int _currentIndex = 0;

  String? get selectedCategory => _selectedCategory;
  int get currentIndex => _currentIndex;
  List<Topic> get myTopics => List.unmodifiable(_myTopics);
  Set<String> get savedIds => Set.unmodifiable(_savedIds);
  List<String> get discussedIds => List.unmodifiable(_discussedIds);

  List<Topic> get allTopics => [...baseTopics, ..._myTopics];

  /// Categories to show in the filter bar ("مواضيعنا" only once it has any).
  List<TopicCategory> get categories => [
    for (final c in topicCategories)
      if (c.id != mineCategoryId || _myTopics.isNotEmpty) c,
  ];

  TopicCategory category(String id) =>
      topicCategories.firstWhere((c) => c.id == id);

  /// The deck: topics of the selected category (or all of them).
  List<Topic> get visibleTopics => [
    for (final t in allTopics)
      if (_selectedCategory == null || t.categoryId == _selectedCategory) t,
  ];

  /// Topics for the "tonight" card on the Activities page.
  List<Topic> get tonightTopics => [
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
  bool isDiscussed(String id) => _discussedIds.contains(id);

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
    if (_discussedIds.contains(id)) return;
    _discussedIds.insert(0, id);
    notifyListeners();
  }

  void addMyTopic(String text) {
    final v = text.trim();
    if (v.isEmpty) return;
    _myTopics.add(
      Topic(
        id: 'm${_myTopics.length}',
        categoryId: mineCategoryId,
        text: v,
        isMine: true,
      ),
    );
    _selectedCategory = mineCategoryId;
    _currentIndex = _myTopics.length - 1;
    notifyListeners();
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
