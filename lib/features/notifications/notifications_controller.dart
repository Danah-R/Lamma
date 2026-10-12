// The one notifications store for the whole app. It lives above
// MaterialApp, so the floating banner and the notifications screen read
// (and write) the same list: reading one anywhere updates the other.

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

import 'notification_model.dart';

bool _demoDefault() {
  if (!const bool.fromEnvironment('DEMO_NOTIFICATIONS', defaultValue: true)) {
    return false;
  }
  try {
    // never inside `flutter test`: the 4s timer would outlive the test
    return !Platform.environment.containsKey('FLUTTER_TEST');
  } catch (_) {
    return true; // web: no Platform
  }
}

/// Shows one sample notification 3.5 seconds after launch, so the banner can
/// be seen. Turn off with `--dart-define=DEMO_NOTIFICATIONS=false`.
final bool kDemoNotifications = _demoDefault();

class NotificationsController extends ChangeNotifier {
  final List<AppNotification> _items = [];
  final StreamController<AppNotification> _new = StreamController.broadcast();

  /// Set by the app shell: takes the user to a notification's target.
  void Function(AppNotification)? onOpen;

  // ---- the floating box under the bell ----
  // Whether it is open lives here so the banner (which sits above every
  // screen) can open the box of whichever bell is on screen.
  final Set<Object> _activeBells = {};
  bool _panelOpen = false;
  bool get panelOpen => _panelOpen;
  bool get hasActiveBell => _activeBells.isNotEmpty;

  /// A bell on the visible screen announces itself (and leaves when hidden).
  void bellShown(Object bell) => _activeBells.add(bell);
  void bellHidden(Object bell) {
    _activeBells.remove(bell);
    if (_activeBells.isEmpty) closePanel();
  }

  void openPanel() {
    if (_panelOpen || !hasActiveBell) return;
    _panelOpen = true;
    notifyListeners();
  }

  void closePanel() {
    if (!_panelOpen) return;
    _panelOpen = false;
    notifyListeners();
  }

  void togglePanel() => _panelOpen ? closePanel() : openPanel();

  /// Newest first.
  List<AppNotification> get items => List.unmodifiable(_items);
  int get unreadCount => _items.where((n) => !n.isRead).length;

  /// Fires for each notification that just arrived (not for the seeded
  /// history): this is what the banner listens to.
  Stream<AppNotification> get onNew => _new.stream;

  AppNotification? byId(String id) {
    for (final n in _items) {
      if (n.id == id) return n;
    }
    return null;
  }

  /// Adds [n] in time order. Nothing is added for my own acts, or when the
  /// id is already there. [announce] = false is for history (no banner).
  void add(AppNotification? n, {bool announce = true}) {
    if (n == null || n.actorId == notificationMeId) return;
    if (byId(n.id) != null) return;
    final at = _items.indexWhere((x) => x.createdAt.isBefore(n.createdAt));
    _items.insert(at < 0 ? _items.length : at, n);
    notifyListeners();
    if (announce) _new.add(n);
  }

  /// Records something *I* did (a vote, a game started): it goes in the list
  /// already read, with no badge and no banner.
  void logOwn(AppNotification? n) {
    if (n == null || byId(n.id) != null) return;
    final read = n.copyWith(isRead: true);
    final at = _items.indexWhere((x) => x.createdAt.isBefore(read.createdAt));
    _items.insert(at < 0 ? _items.length : at, read);
    notifyListeners();
  }

  void markRead(String id) {
    final i = _items.indexWhere((n) => n.id == id);
    if (i < 0 || _items[i].isRead) return;
    _items[i] = _items[i].copyWith(isRead: true);
    notifyListeners();
  }

  void markAllRead() {
    if (unreadCount == 0) return;
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  /// Tap on a notification: mark it read, then go to where it points.
  void open(AppNotification n) {
    markRead(n.id);
    onOpen?.call(n);
  }

  @override
  void dispose() {
    _new.close();
    super.dispose();
  }
}
