import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../screens/activities_colors.dart';
import 'confirm_end_dialog.dart';

/// Full-screen shell for games (no bottom nav). Keeps the screen awake, and
/// while [playing] intercepts the system back to ask for confirmation.
class GameScaffold extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final bool playing;
  final String exitTitle, exitMessage;
  final bool showTimerPaused;

  /// Side padding and safe-area handling; full-bleed screens turn these off.
  final EdgeInsetsGeometry padding;
  final bool safeArea;

  /// Runs instead of popping the route when the player confirms ending
  /// from the system back gesture.
  final VoidCallback? onExit;

  /// Fired when the confirm dialog opens / closes, so the game can pause
  /// and resume its timer.
  final VoidCallback? onExitDialogOpen, onExitDialogClose;

  const GameScaffold({
    super.key,
    required this.child,
    this.backgroundColor = AC.background,
    this.playing = false,
    this.exitTitle = '',
    this.exitMessage = '',
    this.showTimerPaused = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.safeArea = true,
    this.onExit,
    this.onExitDialogOpen,
    this.onExitDialogClose,
  });

  @override
  State<GameScaffold> createState() => _GameScaffoldState();
}

class _GameScaffoldState extends State<GameScaffold> {
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _onPop(bool didPop, Object? result) async {
    if (didPop) return;
    widget.onExitDialogOpen?.call();
    final end = await showConfirmEnd(
      context,
      title: widget.exitTitle,
      message: widget.exitMessage,
      showTimerPaused: widget.showTimerPaused,
    );
    widget.onExitDialogClose?.call();
    if (!end || !mounted) return;
    if (widget.onExit != null) {
      widget.onExit!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !widget.playing,
    onPopInvokedWithResult: _onPop,
    child: Scaffold(
      backgroundColor: widget.backgroundColor,
      body: SafeArea(
        top: widget.safeArea,
        bottom: widget.safeArea,
        child: Padding(padding: widget.padding, child: widget.child),
      ),
    ),
  );
}
