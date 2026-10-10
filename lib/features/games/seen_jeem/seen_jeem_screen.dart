import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';
import '../../../screens/game_illustrations.dart';
import '../shared/confirm_end_dialog.dart';
import '../shared/family_players.dart';
import '../shared/game_scaffold.dart';
import '../shared/motion.dart';
import '../shared/player_avatar.dart';

/// {X} is replaced with the name of the person the question is about.
const seenJeemTemplates = <String>[
  'وش أكلة {X} المفضلة؟',
  'وش أكثر شي يزعّل {X}؟',
  'لو {X} يسافر بكرة، وين بيروح؟',
  'وش أول شي يسويه {X} إذا صحى؟',
  'وش لون {X} المفضل؟',
  'مين أقرب صديق لـ {X}؟',
  'وش الشي اللي {X} ما يقدر يعيش بدونه؟',
  'وش أحلى ذكرى عند {X} من طفولته؟',
  'لو {X} يختار وظيفة ثانية، وش بتكون؟',
  'وش أكثر مسلسل أو برنامج يحبه {X}؟',
];

const _questionOptions = [5, 8, 12];
const _minPlayers = 3;
const _answerInk = Color(0xFF2F6662);

enum _Phase { intro, play, result }

class SeenJeemScreen extends StatefulWidget {
  const SeenJeemScreen({super.key});
  @override
  State<SeenJeemScreen> createState() => _SeenJeemScreenState();
}

class _SeenJeemScreenState extends State<SeenJeemScreen> {
  _Phase _phase = _Phase.intro;
  final Set<int> _picked = {0, 1, 2, 3};
  int _qCount = 8;

  List<int> _players = [];
  List<String> _questions = [];
  int _q = 0;
  final Map<int, int> _pts = {};

  bool get _enough => _picked.length >= _minPlayers;

  void _begin() {
    final t = List.of(seenJeemTemplates)..shuffle();
    setState(() {
      _phase = _Phase.play;
      _players = _picked.toList()..sort();
      _questions = [for (var k = 0; k < _qCount; k++) t[k % t.length]];
      _q = 0;
      _pts.clear();
    });
  }

  void _judge(bool ok) {
    ok ? HapticFeedback.mediumImpact() : HapticFeedback.lightImpact();
    final answerer = _players[(_q + 1) % _players.length];
    setState(() {
      if (ok) _pts[answerer] = (_pts[answerer] ?? 0) + 1;
      _q++;
      if (_q >= _qCount) _phase = _Phase.result;
    });
  }

  void _toResult() {
    if (mounted) setState(() => _phase = _Phase.result);
  }

  Future<void> _confirmEnd() async {
    final l = AppLocalizations.of(context);
    final yes = await showConfirmEnd(
      context,
      title: l.seenEndTitle,
      message: l.seenEndMessage,
      showTimerPaused: false,
    );
    if (yes) _toResult();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GameScaffold(
      playing: _phase == _Phase.play,
      exitTitle: l.seenEndTitle,
      exitMessage: l.seenEndMessage,
      showTimerPaused: false,
      onExit: _toResult,
      child: switch (_phase) {
        _Phase.intro => _buildIntro(l),
        _Phase.play => _buildPlay(l),
        _Phase.result => _buildResult(l),
      },
    );
  }

  // ------------------------------------------------------------- intro
  Widget _buildIntro(AppLocalizations l) {
    final n = _picked.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 16, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _RoundButton(
                      label: MaterialLocalizations.of(context)
                          .backButtonTooltip,
                      onTap: () => Navigator.of(context).pop(),
                      child: const Directionality(
                        textDirection: TextDirection.ltr,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 24,
                          color: AC.ink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: AC.tealTint,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  alignment: Alignment.center,
                  child: const ExcludeSemantics(
                    child: SizedBox(
                      width: 160,
                      height: 130,
                      child: FittedBox(
                        child: SizedBox(
                          width: 78,
                          height: 64,
                          child: GameIllustration('seen'),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l.gamesSinJimTitle,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AC.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.seenDesc,
                  style: const TextStyle(fontSize: 15, color: AC.muted),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      l.seenWhoPlays,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AC.ink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.seenPlayersCount(n) +
                            (_enough ? '' : ' · ${l.seenPickAtLeast3}'),
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontSize: 13, color: AC.muted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (var r = 0; r < familyPlayers.length; r += 3) ...[
                  if (r > 0) const SizedBox(height: 10),
                  Row(
                    children: [
                      for (
                        var i = r;
                        i < r + 3 && i < familyPlayers.length;
                        i++
                      ) ...[
                        if (i > r) const SizedBox(width: 10),
                        Expanded(
                          child: _PlayerTile(
                            player: familyPlayers[i],
                            selected: _picked.contains(i),
                            onTap: () => setState(
                              () => _picked.contains(i)
                                  ? _picked.remove(i)
                                  : _picked.add(i),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                Text(
                  l.seenQuestionCount,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AC.ink,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final c in _questionOptions) ...[
                      if (c != _questionOptions.first) const SizedBox(width: 8),
                      Expanded(
                        child: _CountChip(
                          label: l.seenQuestionsOption(c),
                          selected: c == _qCount,
                          onTap: () => setState(() => _qCount = c),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _StartButton(label: l.seenStart, enabled: _enough, onTap: _begin),
        const SizedBox(height: 16),
      ],
    );
  }

  // -------------------------------------------------------------- play
  Widget _buildPlay(AppLocalizations l) {
    final n = _players.length;
    final about = familyPlayers[_players[_q % n]];
    final answerer = familyPlayers[_players[(_q + 1) % n]];
    final question = _questions[_q].replaceAll('{X}', about.name);
    final key = ValueKey(_q);
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _RoundButton(
                label: l.seenCloseLabel,
                onTap: _confirmEnd,
                child: const Icon(Icons.close_rounded, size: 18, color: AC.ink),
              ),
              Expanded(
                child: Text(
                  l.seenQuestionNo(_q + 1, _qCount),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AC.ink,
                  ),
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AC.track,
              borderRadius: BorderRadius.circular(4),
            ),
            clipBehavior: Clip.antiAlias,
            child: AnimatedFractionallySizedBox(
              duration: motionDuration(
                context,
                const Duration(milliseconds: 300),
              ),
              alignment: AlignmentDirectional.centerStart,
              widthFactor: _q / _qCount,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: AC.teal,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                clipBehavior: Clip.none,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      // Moves left to right: leaves to the right, enters from the left (physical).
                      transitionBuilder: (child, anim) {
                        if (reduceMotion(context)) {
                          return FadeTransition(opacity: anim, child: child);
                        }
                        final incoming = child.key == key;
                        return SlideTransition(
                          textDirection: TextDirection.ltr,
                          position: Tween<Offset>(
                            begin: Offset(incoming ? -1 : 1, 0),
                            end: Offset.zero,
                          ).animate(anim),
                          child: FadeTransition(opacity: anim, child: child),
                        );
                      },
                      child: _QuestionCard(
                        key: key,
                        about: about,
                        answerer: answerer,
                        question: question,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l.seenIsAnswerRight(about.name),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, color: AC.muted),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // RTL: first child sits on the right.
                        Expanded(
                          child: _JudgeButton(
                            label: l.seenWrong,
                            background: Colors.white,
                            foreground: AC.ink,
                            border: AC.border,
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AC.brick,
                            ),
                            onTap: () => _judge(false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _JudgeButton(
                            label: l.seenRight,
                            background: AC.teal,
                            foreground: Colors.white,
                            icon: const Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            onTap: () => _judge(true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final i in _players)
                Container(
                  padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 10, 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AC.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PlayerAvatar(player: familyPlayers[i], size: 24),
                      const SizedBox(width: 6),
                      Text(
                        '${_pts[i] ?? 0}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AC.ink,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ result
  Widget _buildResult(AppLocalizations l) {
    final ranked = List.of(_players)
      ..sort((a, b) => (_pts[b] ?? 0).compareTo(_pts[a] ?? 0));
    final win = familyPlayers[ranked.first];
    const medals = [AC.mustard, Color(0xFFC9CFDD), AC.salmon];
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
            decoration: BoxDecoration(
              color: AC.teal,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Text(
                  l.seenWinnerLabel,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: .9),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: PlayerAvatar(player: win, size: 64),
                ),
                const SizedBox(height: 8),
                Text(
                  win.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    l.seenPointsCount(_pts[ranked.first] ?? 0),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AC.border),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (var k = 0; k < ranked.length; k++)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: k == 0
                              ? null
                              : const Border(top: BorderSide(color: AC.track)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: k < medals.length ? medals[k] : AC.track,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${k + 1}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AC.navy,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            PlayerAvatar(
                              player: familyPlayers[ranked[k]],
                              size: 36,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                familyPlayers[ranked[k]].name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AC.ink,
                                ),
                              ),
                            ),
                            Text(
                              '${_pts[ranked[k]] ?? 0}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AC.ink,
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
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ResultButton(
                  label: l.seenBackToGames,
                  background: Colors.white,
                  foreground: AC.ink,
                  border: AC.border,
                  weight: FontWeight.w700,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ResultButton(
                  label: l.seenPlayAgain,
                  background: AC.brick,
                  foreground: Colors.white,
                  onTap: _begin,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------- pieces

class _RoundButton extends StatelessWidget {
  final Widget child;
  final String label;
  final VoidCallback onTap;
  const _RoundButton({
    required this.child,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    excludeSemantics: true,
    child: Material(
      color: Colors.white,
      shape: const CircleBorder(side: BorderSide(color: AC.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 44, height: 44, child: Center(child: child)),
      ),
    ),
  );
}

class _PlayerTile extends StatelessWidget {
  final FamilyPlayer player;
  final bool selected;
  final VoidCallback onTap;
  const _PlayerTile({
    required this.player,
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
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: selected ? 1 : .6,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 92,
          decoration: BoxDecoration(
            color: selected ? Colors.white : AC.track,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AC.teal : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PlayerAvatar(player: player, size: 40),
              const SizedBox(height: 6),
              Text(
                player.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AC.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _CountChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CountChip({
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AC.navy : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AC.navy : AC.border),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AC.ink,
          ),
        ),
      ),
    ),
  );
}

class _StartButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  const _StartButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: enabled
          ? const [
              BoxShadow(
                color: Color(0x4D9A4A3E),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ]
          : null,
    ),
    child: Material(
      color: enabled ? AC.brick : const Color(0xFFC9A79F),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? onTap : null,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
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

class _QuestionCard extends StatelessWidget {
  final FamilyPlayer about, answerer;
  final String question;
  const _QuestionCard({
    super.key,
    required this.about,
    required this.answerer,
    required this.question,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AC.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A5B3A28),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PlayerAvatar(player: about, size: 48),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.seenAbout,
                    style: const TextStyle(fontSize: 13, color: AC.muted),
                  ),
                  Text(
                    about.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AC.ink,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question,
            style: const TextStyle(
              fontSize: 26,
              height: 1.5,
              fontWeight: FontWeight.w800,
              color: AC.navy,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AC.tealTint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                PlayerAvatar(player: answerer, size: 32),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: answerer.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: _answerInk,
                          ),
                        ),
                        TextSpan(text: ' ${l.seenAnswersAloud}'),
                      ],
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: AC.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JudgeButton extends StatelessWidget {
  final String label;
  final Color background, foreground;
  final Color? border;
  final Widget icon;
  final VoidCallback onTap;
  const _JudgeButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.icon,
    required this.onTap,
    this.border,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: background,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: border == null ? BorderSide.none : BorderSide(color: border!),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ResultButton extends StatelessWidget {
  final String label;
  final Color background, foreground;
  final Color? border;
  final FontWeight weight;
  final VoidCallback onTap;
  const _ResultButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.border,
    this.weight = FontWeight.w800,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: background,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: border == null ? BorderSide.none : BorderSide(color: border!),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: SizedBox(
        height: 54,
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: weight,
              color: foreground,
            ),
          ),
        ),
      ),
    ),
  );
}
