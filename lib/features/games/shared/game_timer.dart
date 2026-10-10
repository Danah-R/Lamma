import 'dart:async';

import 'package:flutter/foundation.dart';

/// Countdown timer for games. [pause] really stops the ticking.
class GameTimer extends ChangeNotifier {
  GameTimer({this.onFinished});

  /// Called once when the countdown reaches zero.
  VoidCallback? onFinished;

  Timer? _ticker;
  int _secondsLeft = 0;
  bool _running = false;

  int get secondsLeft => _secondsLeft;
  bool get isRunning => _running;

  void start(int seconds) {
    _cancel();
    _secondsLeft = seconds;
    _running = true;
    _schedule();
    notifyListeners();
  }

  void pause() {
    if (!_running) return;
    _cancel();
    _running = false;
    notifyListeners();
  }

  void resume() {
    if (_running || _secondsLeft <= 0) return;
    _running = true;
    _schedule();
    notifyListeners();
  }

  void stop() {
    _cancel();
    _running = false;
    _secondsLeft = 0;
    notifyListeners();
  }

  void _schedule() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _secondsLeft--;
      if (_secondsLeft <= 0) {
        _secondsLeft = 0;
        _cancel();
        _running = false;
        notifyListeners();
        onFinished?.call();
      } else {
        notifyListeners();
      }
    });
  }

  void _cancel() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }
}
