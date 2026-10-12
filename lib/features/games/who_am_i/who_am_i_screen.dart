import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';
import '../shared/confirm_end_dialog.dart';
import '../shared/game_scaffold.dart';
import '../shared/game_timer.dart';
import '../shared/motion.dart';
import 'who_am_i_data.dart';

enum _Phase { intro, play, result }

class _Answer {
  final String word;
  final bool ok;
  const _Answer(this.word, this.ok);
}

class WhoAmIScreen extends StatefulWidget {
  const WhoAmIScreen({super.key});
  @override
  State<WhoAmIScreen> createState() => _WhoAmIScreenState();
}

class _WhoAmIScreenState extends State<WhoAmIScreen> {
  static const _durations = [30, 60, 90];

  late final GameTimer _timer = GameTimer(onFinished: _toResult);
  Timer? _flashTimer;

  _Phase _phase = _Phase.intro;
  WhoAmICategory _cat = whoAmICategories.first;
  int _total = 60;

  List<String> _order = [];
  int _i = 0;
  int _score = 0;
  final List<_Answer> _history = [];
  bool? _flashOk; // null = no flash
  int _flashN = 0;

  @override
  void dispose() {
    _timer.dispose();
    _flashTimer?.cancel();
    super.dispose();
  }

  void _begin() {
    final order = List<String>.of(_cat.words)..shuffle();
    setState(() {
      _phase = _Phase.play;
      _order = order;
      _i = 0;
      _score = 0;
      _history.clear();
      _flashOk = null;
    });
    _timer.start(_total);
  }

  void _toResult() {
    if (!mounted || _phase != _Phase.play) return;
    _timer.stop();
    _flashTimer?.cancel();
    setState(() {
      _phase = _Phase.result;
      _flashOk = null;
    });
  }

  void _answer(bool ok) {
    if (_phase != _Phase.play) return;
    ok ? HapticFeedback.mediumImpact() : HapticFeedback.lightImpact();
    _history.add(_Answer(_order[_i], ok));
    _flashTimer?.cancel();
    setState(() {
      _i++;
      if (ok) _score++;
      _flashOk = ok;
      _flashN++;
    });
    if (_i >= _order.length) {
      _toResult();
      return;
    }
    _flashTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _flashOk = null);
    });
  }

  Future<void> _confirmEnd() async {
    final l = AppLocalizations.of(context);
    _timer.pause();
    final end = await showConfirmEnd(
      context,
      title: l.whoAmIEndTitle,
      message: l.whoAmIEndMessage,
      showTimerPaused: true,
    );
    if (!mounted) return;
    if (end) {
      _toResult();
    } else {
      _timer.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final playing = _phase == _Phase.play;
    return GameScaffold(
      backgroundColor: playing ? _cat.bg : AC.background,
      playing: playing,
      exitTitle: l.whoAmIEndTitle,
      exitMessage: l.whoAmIEndMessage,
      padding: playing
          ? const EdgeInsets.fromLTRB(20, 8, 20, 12)
          : EdgeInsets.zero,
      safeArea: playing,
      onExitDialogOpen: _timer.pause,
      onExitDialogClose: () {
        if (_phase == _Phase.play) _timer.resume();
      },
      onExit: _toResult,
      child: switch (_phase) {
        _Phase.intro => _buildIntro(l),
        _Phase.play => _buildPlay(l),
        _Phase.result => _buildResult(l),
      },
    );
  }

  // ---------------------------------------------------------------- intro
  Widget _buildIntro(AppLocalizations l) => LayoutBuilder(
    builder: (context, c) => SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: c.maxHeight),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _IntroHero(
                cat: _cat,
                catLabel: _cat.label(l),
                onBack: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _HowTile(Icons.phone_android_rounded, l.whoAmIHow1),
                          const SizedBox(width: 8),
                          _HowTile(
                            Icons.chat_bubble_outline_rounded,
                            l.whoAmIHow2,
                          ),
                          const SizedBox(width: 8),
                          _HowTile(Icons.check_rounded, l.whoAmIHow3),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        l.whoAmIChooseCategory,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AC.ink,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Semantics(
                        container: true,
                        label: l.whoAmIChooseCategory,
                        child: Column(
                          children: [
                            for (var r = 0; r < whoAmICategories.length; r += 2)
                              Padding(
                                padding: EdgeInsets.only(top: r == 0 ? 0 : 10),
                                child: SizedBox(
                                  height: 72,
                                  child: Row(
                                    children: [
                                      for (final c
                                          in whoAmICategories
                                              .skip(r)
                                              .take(2)) ...[
                                        if (c != whoAmICategories[r])
                                          const SizedBox(width: 10),
                                        Expanded(
                                          child: _CategoryTile(
                                            cat: c,
                                            label: c.label(l),
                                            selected: c.id == _cat.id,
                                            onTap: () =>
                                                setState(() => _cat = c),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        l.whoAmIRoundTime,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AC.ink,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AC.track,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            for (final t in _durations)
                              Expanded(
                                child: _SegmentButton(
                                  label: l.whoAmISeconds(t),
                                  selected: t == _total,
                                  onTap: () => setState(() => _total = t),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: 16),
                      _StartButton(
                        label: l.whoAmIStart,
                        color: _cat.bg,
                        onTap: _begin,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // ----------------------------------------------------------------- play
  Widget _buildPlay(AppLocalizations l) {
    final cat = _cat;
    final word = _order[_i];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _CircleButton(
              semanticLabel: l.whoAmIEndRound,
              onTap: _confirmEnd,
              child: const Icon(
                Icons.close_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Center(child: _Pill(label: cat.label(l))),
            ),
            Semantics(
              label: l.whoAmIScoreLabel,
              child: Container(
                constraints: const BoxConstraints(minWidth: 44),
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  '$_score',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AC.navy,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        ListenableBuilder(
          listenable: _timer,
          builder: (context, _) {
            final left = _timer.secondsLeft;
            final low = left <= 10;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        l.whoAmITime,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: .9),
                        ),
                      ),
                    ),
                    Semantics(
                      label: l.whoAmITimeLeft(left),
                      child: Text(
                        '$left',
                        style: const TextStyle(
                          fontSize: 30,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .22),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AnimatedFractionallySizedBox(
                    duration: motionDuration(
                      context,
                      const Duration(seconds: 1),
                    ),
                    curve: Curves.linear,
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: _total == 0 ? 0 : left / _total,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: low ? AC.salmonTint : Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              _CardBack(angle: -5 * math.pi / 180, scale: .94, alpha: .2),
              _CardBack(angle: 4 * math.pi / 180, scale: .97, alpha: .35),
              Container(
                height: 300,
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .22),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: cat.tint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        l.whoAmIWordNo(_i + 1),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: cat.tagInk,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: reduceMotion(context)
                            ? child
                            : ScaleTransition(
                                scale: Tween<double>(
                                  begin: .9,
                                  end: 1,
                                ).animate(anim),
                                child: child,
                              ),
                      ),
                      child: Semantics(
                        key: ValueKey(_i),
                        liveRegion: true,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            word,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 50,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                              color: AC.navy,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_flashOk != null)
                Positioned(
                  top: 18,
                  child: _FlashBadge(
                    key: ValueKey(_flashN),
                    ok: _flashOk!,
                    text: _flashOk! ? l.whoAmIFlashCorrect : l.whoAmIFlashSkip,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            // RTL: first child sits on the right.
            Expanded(
              child: _ActionButton(
                label: l.whoAmISkip,
                height: 68,
                background: Colors.transparent,
                foreground: Colors.white,
                border: Colors.white.withValues(alpha: .55),
                icon: const Directionality(
                  textDirection: TextDirection.ltr,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                onTap: () => _answer(false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                label: l.whoAmIGotIt,
                height: 68,
                background: Colors.white,
                foreground: cat.bg,
                shadow: true,
                icon: Icon(Icons.check_rounded, size: 22, color: cat.bg),
                onTap: () => _answer(true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --------------------------------------------------------------- result
  Widget _buildResult(AppLocalizations l) {
    final skipped = _history.where((h) => !h.ok).length;
    final verdict = _score >= 8
        ? l.whoAmIVerdictTop
        : _score >= 4
        ? l.whoAmIVerdictGood
        : l.whoAmIVerdictLow;
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(20, top + 24, 20, 26),
          decoration: BoxDecoration(
            color: _cat.bg,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(32),
            ),
          ),
          child: Column(
            children: [
              const Icon(Icons.emoji_events, size: 76, color: AC.mustard),
              const SizedBox(height: 4),
              Text(
                l.whoAmITimesUp,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: .9),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                verdict,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ScoreBox(
                    value: _score,
                    label: l.whoAmIKnew,
                    background: Colors.white,
                    foreground: AC.navy,
                  ),
                  const SizedBox(width: 10),
                  _ScoreBox(
                    value: skipped,
                    label: l.whoAmISkipped,
                    background: Colors.white.withValues(alpha: .18),
                    foreground: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 24 + bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.whoAmIRoundWords,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AC.ink,
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final h in _history) _HistoryChip(answer: h),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: l.whoAmIBackToGames,
                        height: 54,
                        background: Colors.white,
                        foreground: AC.ink,
                        border: AC.border,
                        weight: FontWeight.w700,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        label: l.whoAmIAgain,
                        height: 54,
                        background: AC.brick,
                        foreground: Colors.white,
                        radius: 16,
                        onTap: _begin,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------ pieces

class _IntroHero extends StatefulWidget {
  final WhoAmICategory cat;
  final String catLabel;
  final VoidCallback onBack;
  const _IntroHero({
    required this.cat,
    required this.catLabel,
    required this.onBack,
  });
  @override
  State<_IntroHero> createState() => _IntroHeroState();
}

class _IntroHeroState extends State<_IntroHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _float.stop();
    } else if (!_float.isAnimating) {
      _float.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  Widget _backCard(double angle, double dx, double alpha) => Positioned(
    top: 18,
    child: Transform.rotate(
      angle: angle * math.pi / 180,
      child: Transform.translate(
        offset: Offset(dx, 0),
        child: Container(
          width: 128,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: alpha),
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final top = MediaQuery.paddingOf(context).top;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.fromLTRB(20, top + 12, 20, 24),
      decoration: BoxDecoration(
        color: widget.cat.bg,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CircleButton(
                semanticLabel: MaterialLocalizations.of(context)
                    .backButtonTooltip,
                onTap: widget.onBack,
                child: const Directionality(
                  textDirection: TextDirection.ltr,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: _Pill(label: l.whoAmIBadge, size: 13, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ExcludeSemantics(
            child: AnimatedBuilder(
              animation: _float,
              builder: (context, child) => Transform.translate(
                offset: Offset(
                  0,
                  -6 * Curves.easeInOut.transform(_float.value),
                ),
                child: child,
              ),
              child: SizedBox(
                height: 170,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    _backCard(-12, -34, .22),
                    _backCard(10, 34, .35),
                    Positioned(
                      top: 10,
                      child: Container(
                        width: 132,
                        height: 156,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .18),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontFamily: DefaultTextStyle.of(context)
                                    .style
                                    .fontFamily,
                                fontSize: 64,
                                height: 1,
                                fontWeight: FontWeight.w800,
                                color: widget.cat.bg,
                              ),
                              child: const Text('؟'),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.catLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AC.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context).gamesWhoAmITitle,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.whoAmIHeroDesc,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: .92),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final String semanticLabel;
  const _CircleButton({
    required this.child,
    required this.onTap,
    required this.semanticLabel,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel,
    excludeSemantics: true,
    child: Material(
      color: Colors.white.withValues(alpha: .18),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 44, height: 44, child: Center(child: child)),
      ),
    ),
  );
}

class _Pill extends StatelessWidget {
  final String label;
  final double size, vertical;
  const _Pill({required this.label, this.size = 14, this.vertical = 8});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 14, vertical: vertical),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .18),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: size,
        fontWeight: size == 13 ? FontWeight.w700 : FontWeight.w800,
        color: Colors.white,
      ),
    ),
  );
}

class _HowTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HowTile(this.icon, this.label);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AC.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 26, color: AC.brick),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              fontWeight: FontWeight.w700,
              color: AC.ink,
            ),
          ),
        ],
      ),
    ),
  );
}

class _CategoryTile extends StatelessWidget {
  final WhoAmICategory cat;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryTile({
    required this.cat,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      button: true,
      selected: selected,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: selected ? cat.tint : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected ? cat.bg : AC.border,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: cat.iconBg ?? cat.bg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          cat.icon,
                          size: 22,
                          color: cat.id == 'places' ? AC.navy : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AC.ink,
                              ),
                            ),
                            Text(
                              l.whoAmIWordsCount(cat.words.length),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AC.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (selected)
            Positioned(
              top: -7,
              left: -7,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: cat.bg,
                  shape: BoxShape.circle,
                  border: Border.all(color: AC.background, width: 2),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      // 44 high hit area around the 40 high visual segment.
      child: Container(
        height: 44,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          constraints: const BoxConstraints(minWidth: 56),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AC.cardShadow,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: selected ? AC.ink : AC.muted,
            ),
          ),
        ),
      ),
    ),
  );
}

class _StartButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _StartButton({
    required this.label,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: AC.navy.withValues(alpha: .22),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          height: 58,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              const Directionality(
                textDirection: TextDirection.ltr,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _CardBack extends StatelessWidget {
  final double angle, scale, alpha;
  const _CardBack({
    required this.angle,
    required this.scale,
    required this.alpha,
  });
  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: angle,
    child: Transform.scale(
      scale: scale,
      child: Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: alpha),
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
  );
}

class _FlashBadge extends StatelessWidget {
  final bool ok;
  final String text;
  const _FlashBadge({super.key, required this.ok, required this.text});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 900),
    builder: (context, t, child) {
      final opacity = t < .2 ? t / .2 : (t > .8 ? (1 - t) / .2 : 1.0);
      final dy = t < .2
          ? 8 * (1 - t / .2)
          : (t > .8 ? -8 * (t - .8) / .2 : 0.0);
      return Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: reduceMotion(context)
            ? child
            : Transform.translate(offset: Offset(0, dy), child: child),
      );
    },
    child: Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ok ? AC.mustard : AC.ink,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: ok ? AC.navy : Colors.white,
        ),
      ),
    ),
  );
}

class _ActionButton extends StatelessWidget {
  final String label;
  final double height, radius;
  final Color background, foreground;
  final Color? border;
  final Widget? icon;
  final bool shadow;
  final FontWeight weight;
  final VoidCallback onTap;
  const _ActionButton({
    required this.label,
    required this.height,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.border,
    this.icon,
    this.shadow = false,
    this.radius = 22,
    this.weight = FontWeight.w800,
  });
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      boxShadow: shadow
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: .18),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ]
          : null,
    ),
    child: Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: border == null
            ? BorderSide.none
            : BorderSide(color: border!, width: height == 68 ? 2 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: height == 68 ? 18 : 16,
                    fontWeight: weight,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ScoreBox extends StatelessWidget {
  final int value;
  final String label;
  final Color background, foreground;
  const _ScoreBox({
    required this.value,
    required this.label,
    required this.background,
    required this.foreground,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 28,
            height: 1,
            fontWeight: FontWeight.w800,
            color: foreground,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: foreground,
          ),
        ),
      ],
    ),
  );
}

class _HistoryChip extends StatelessWidget {
  final _Answer answer;
  const _HistoryChip({required this.answer});
  @override
  Widget build(BuildContext context) {
    final ok = answer.ok;
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: ok ? AC.tealTint : Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: ok ? null : Border.all(color: AC.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ok) ...[
            const Icon(Icons.check_rounded, size: 14, color: Color(0xFF2F6662)),
            const SizedBox(width: 6),
          ],
          Text(
            answer.word,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: ok ? const Color(0xFF2F6662) : AC.muted,
              decoration: ok ? null : TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }
}
