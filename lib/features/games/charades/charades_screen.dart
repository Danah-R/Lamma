import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';
import '../../../screens/game_illustrations.dart';
import '../shared/confirm_end_dialog.dart';
import '../shared/family_players.dart';
import '../shared/game_scaffold.dart';
import '../shared/game_timer.dart';
import '../shared/motion.dart';
import '../shared/player_avatar.dart';
import 'charades_data.dart';

enum _Phase { setup, handoff, play, result }

class CharadesScreen extends StatefulWidget {
  const CharadesScreen({super.key});
  @override
  State<CharadesScreen> createState() => _CharadesScreenState();
}

class _CharadesScreenState extends State<CharadesScreen> {
  late final GameTimer _timer = GameTimer(onFinished: _onTimeUp);
  final _nameA = TextEditingController();
  final _nameB = TextEditingController();
  bool _namesInit = false;

  _Phase _phase = _Phase.setup;
  // team index (0 / 1) per family player, null = sitting out.
  final List<int?> _team = [
    for (var i = 0; i < familyPlayers.length; i++) i % 2,
  ];
  int _rounds = 3;

  int _turn = 0; // 0-based; even = team A, odd = team B
  final List<int> _score = [0, 0];
  final Map<int, int> _points = {};
  List<String> _deck = [];
  int _wordI = 0;
  bool _revealed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_namesInit) {
      final l = AppLocalizations.of(context);
      _nameA.text = l.charadesDefaultTeamA;
      _nameB.text = l.charadesDefaultTeamB;
      _namesInit = true;
    }
  }

  @override
  void dispose() {
    _timer.dispose();
    _nameA.dispose();
    _nameB.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ helpers
  String _teamName(AppLocalizations l, int t) {
    final v = (t == 0 ? _nameA : _nameB).text.trim();
    if (v.isNotEmpty) return v;
    return t == 0 ? l.charadesFallbackTeamA : l.charadesFallbackTeamB;
  }

  List<int> _members(int t) => [
    for (var i = 0; i < _team.length; i++)
      if (_team[i] == t) i,
  ];

  bool get _ready => _members(0).isNotEmpty && _members(1).isNotEmpty;
  int get _turnTeam => _turn % 2;

  int _actorIndex() {
    final list = _members(_turnTeam);
    return list[(_turn ~/ 2) % list.length];
  }

  // -------------------------------------------------------------- flow
  void _startGame() {
    setState(() {
      _phase = _Phase.handoff;
      _turn = 0;
      _score[0] = 0;
      _score[1] = 0;
      _points.clear();
      _deck = List.of(charadesWords)..shuffle();
      _wordI = 0;
      _revealed = false;
    });
  }

  void _beginTurn() {
    setState(() {
      _phase = _Phase.play;
      _revealed = false;
    });
    _timer.start(charadesTurnSeconds);
  }

  void _onTimeUp() {
    if (mounted && _phase == _Phase.play) _stopTurn();
  }

  void _stopTurn() {
    _timer.stop();
    final next = _turn + 1;
    setState(() {
      _turn = next;
      _revealed = false;
      _phase = next >= _rounds * 2 ? _Phase.result : _Phase.handoff;
    });
  }

  void _toResult() {
    _timer.stop();
    if (!mounted) return;
    setState(() {
      _phase = _Phase.result;
      _revealed = false;
    });
  }

  void _answer(bool ok) {
    ok ? HapticFeedback.mediumImpact() : HapticFeedback.lightImpact();
    setState(() {
      if (ok) {
        _score[_turnTeam]++;
        final a = _actorIndex();
        _points[a] = (_points[a] ?? 0) + 1;
      }
      _wordI++;
      _revealed = false;
    });
  }

  Future<void> _confirmEndTurn() async {
    final l = AppLocalizations.of(context);
    _timer.pause();
    final yes = await showConfirmEnd(
      context,
      title: l.charadesEndTurnTitle,
      message: l.charadesEndTurnMessage(_teamName(l, 1 - _turnTeam)),
      showTimerPaused: true,
    );
    if (!mounted) return;
    yes ? _stopTurn() : _timer.resume();
  }

  Future<void> _confirmEndGame() async {
    final l = AppLocalizations.of(context);
    final inPlay = _phase == _Phase.play;
    if (inPlay) _timer.pause();
    final yes = await showConfirmEnd(
      context,
      title: l.charadesEndGameTitle,
      message: l.charadesEndGameMessage,
      showTimerPaused: inPlay,
    );
    if (!mounted) return;
    if (yes) {
      _toResult();
    } else if (inPlay) {
      _timer.resume();
    }
  }

  // ------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final mid = _phase == _Phase.handoff || _phase == _Phase.play;
    return GameScaffold(
      backgroundColor: _phase == _Phase.handoff
          ? charadesTeams[_turnTeam].color
          : AC.background,
      playing: mid,
      exitTitle: l.charadesEndGameTitle,
      exitMessage: l.charadesEndGameMessage,
      showTimerPaused: _phase == _Phase.play,
      onExitDialogOpen: () {
        if (_phase == _Phase.play) _timer.pause();
      },
      onExitDialogClose: () {
        if (_phase == _Phase.play) _timer.resume();
      },
      onExit: _toResult,
      child: switch (_phase) {
        _Phase.setup => _buildSetup(l),
        _Phase.handoff => _buildHandoff(l),
        _Phase.play => _buildPlay(l),
        _Phase.result => _buildResult(l),
      },
    );
  }

  // ------------------------------------------------------------- setup
  Widget _buildSetup(AppLocalizations l) {
    final shortA = _short(_teamName(l, 0));
    final shortB = _short(_teamName(l, 1));
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
                    _RoundBack(onTap: () => Navigator.of(context).pop()),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.gamesCharadesTitle,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AC.ink,
                            ),
                          ),
                          Text(
                            l.charadesSetupDesc,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AC.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ExcludeSemantics(
                      child: SizedBox(
                        width: 52,
                        height: 44,
                        child: FittedBox(
                          child: SizedBox(
                            width: 78,
                            height: 64,
                            child: GameIllustration('charades'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _TeamNameBox(
                        style: charadesTeams[0],
                        label: l.charadesTeamLabelA,
                        controller: _nameA,
                        count: l.charadesMembersCount(_members(0).length),
                        onChanged: () => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TeamNameBox(
                        style: charadesTeams[1],
                        label: l.charadesTeamLabelB,
                        controller: _nameB,
                        count: l.charadesMembersCount(_members(1).length),
                        onChanged: () => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      l.charadesWhoWithWho,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AC.ink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.charadesTapToPick,
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontSize: 12, color: AC.muted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AC.border),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < familyPlayers.length; i++)
                        _PlayerRow(
                          player: familyPlayers[i],
                          team: _team[i],
                          shortA: shortA,
                          shortB: shortB,
                          first: i == 0,
                          groupLabel: l.charadesPlayerTeamGroup(
                            familyPlayers[i].name,
                          ),
                          onPick: (t) => setState(
                            () => _team[i] = _team[i] == t ? null : t,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l.charadesRounds,
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
                      for (final n in charadesRoundOptions)
                        Expanded(
                          child: _Segment(
                            label: l.charadesRoundsOption(n),
                            selected: n == _rounds,
                            onTap: () => setState(() => _rounds = n),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (MediaQuery.viewInsetsOf(context).bottom == 0) ...[
          SizedBox(
            height: 18,
            child: _ready
                ? null
                : Center(
                    child: Text(
                      l.charadesNeedMembers,
                      style: const TextStyle(fontSize: 13, color: AC.brick),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          _BigButton(
            label: l.charadesStart,
            height: 56,
            radius: 16,
            background: _ready ? AC.brick : const Color(0xFFC9A79F),
            foreground: Colors.white,
            shadow: _ready,
            trailing: const Directionality(
              textDirection: TextDirection.ltr,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            onTap: _ready ? _startGame : null,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  String _short(String s) => s.length > 6 ? '${s.substring(0, 6)}…' : s;

  // ----------------------------------------------------------- handoff
  Widget _buildHandoff(AppLocalizations l) {
    final t = _turnTeam;
    final actor = familyPlayers[_actorIndex()];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                l.charadesRoundOf(_turn ~/ 2 + 1, _rounds),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: .9),
                ),
              ),
            ),
            _EndGameOutline(
              label: l.charadesEndGame,
              onTap: _confirmEndGame,
              color: Colors.white,
              background: Colors.white.withValues(alpha: .22),
              border: Colors.white.withValues(alpha: .7),
              height: 44,
            ),
          ],
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l.charadesTeamTurn,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: .9),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _teamName(l, t),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 38,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: PlayerAvatar(player: actor, size: 46),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.charadesActorThisTime,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: .85),
                              ),
                            ),
                            Text(
                              actor.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 270),
                    child: Text(
                      l.charadesPassPhone(actor.name),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.white.withValues(alpha: .9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _HandoffScore(name: _teamName(l, 0), score: _score[0]),
                      const SizedBox(width: 10),
                      _HandoffScore(name: _teamName(l, 1), score: _score[1]),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        _BigButton(
          label: l.charadesImReady(actor.name),
          height: 58,
          radius: 18,
          background: AC.background,
          foreground: AC.navy,
          fontSize: 17,
          onTap: _beginTurn,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // -------------------------------------------------------------- play
  Widget _buildPlay(AppLocalizations l) {
    final t = _turnTeam;
    final team = charadesTeams[t];
    final actor = familyPlayers[_actorIndex()];
    final word = _deck[_wordI % _deck.length];
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (var k = 0; k < 2; k++) ...[
                if (k == 1) const SizedBox(width: 10),
                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: t == k ? 1 : .55,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: charadesTeams[k].tint,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: t == k
                              ? charadesTeams[k].ink
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _teamName(l, k),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: charadesTeams[k].ink,
                              ),
                            ),
                          ),
                          Text(
                            '${_score[k]}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: charadesTeams[k].ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          ListenableBuilder(
            listenable: _timer,
            builder: (context, _) {
              final left = _timer.secondsLeft;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      PlayerAvatar(player: actor, size: 26),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l.charadesActing(actor.name),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AC.ink,
                          ),
                        ),
                      ),
                      Text(
                        l.charadesSecondsShort(left),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: left <= 10 ? AC.brick : AC.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: AC.track,
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
                      widthFactor: left / charadesTurnSeconds,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: team.color,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AC.border),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1F5B3A28),
                            blurRadius: 30,
                            offset: Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AC.salmonTint,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              l.charadesActIt,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AC.brick,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _revealed
                                ? Text(
                                    word,
                                    key: ValueKey('w$_wordI'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 38,
                                      height: 1.3,
                                      fontWeight: FontWeight.w800,
                                      color: AC.navy,
                                    ),
                                  )
                                : _RevealButton(
                                    key: ValueKey('h$_wordI'),
                                    label: l.charadesTapToReveal,
                                    onTap: () =>
                                        setState(() => _revealed = true),
                                  ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            l.charadesNoTalking,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AC.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        // RTL: first child sits on the right.
                        Expanded(
                          child: _BigButton(
                            label: l.charadesSkip,
                            height: 60,
                            radius: 18,
                            background: Colors.white,
                            foreground: AC.ink,
                            border: AC.border,
                            leading: const Directionality(
                              textDirection: TextDirection.ltr,
                              child: Icon(
                                Icons.arrow_back_rounded,
                                size: 18,
                                color: AC.ink,
                              ),
                            ),
                            onTap: () => _answer(false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _BigButton(
                            label: l.charadesCorrect,
                            height: 60,
                            radius: 18,
                            background: AC.teal,
                            foreground: Colors.white,
                            leading: const Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            onTap: () => _answer(true),
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
          Row(
            children: [
              Expanded(
                child: _BigButton(
                  label: l.charadesEndTurn,
                  height: 44,
                  radius: 14,
                  background: AC.track,
                  foreground: AC.ink,
                  fontSize: 14,
                  weight: FontWeight.w700,
                  onTap: _confirmEndTurn,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _EndGameOutline(
                  label: l.charadesEndGame,
                  onTap: _confirmEndGame,
                  color: AC.brick,
                  background: AC.salmonTint,
                  border: const Color(0xFFE9BFAF),
                  height: 44,
                  fill: true,
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
    final tie = _score[0] == _score[1];
    final win = _score[0] > _score[1] ? 0 : 1;
    final ranked = [
      for (var i = 0; i < _team.length; i++)
        if (_team[i] != null) i,
    ]..sort((a, b) => (_points[b] ?? 0).compareTo(_points[a] ?? 0));
    final top = ranked.isEmpty ? 0 : (_points[ranked.first] ?? 0);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              color: tie ? AC.teal : charadesTeams[win].color,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              children: [
                const SizedBox(
                  width: 56,
                  height: 46,
                  child: CustomPaint(painter: _CrownPainter()),
                ),
                const SizedBox(height: 4),
                Text(
                  tie ? l.charadesTie : l.charadesWinnerTeam,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: .9),
                  ),
                ),
                Text(
                  tie ? l.charadesEveryoneWon : _teamName(l, win),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var k = 0; k < 2; k++) ...[
                if (k == 1) const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: charadesTeams[k].tint,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _teamName(l, k),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: charadesTeams[k].ink,
                          ),
                        ),
                        Text(
                          '${_score[k]}',
                          style: TextStyle(
                            fontSize: 36,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            color: charadesTeams[k].ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AC.border),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 4),
                      child: Text(
                        l.charadesPlayerPoints,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AC.ink,
                        ),
                      ),
                    ),
                    for (var k = 0; k < ranked.length; k++)
                      _RankRow(
                        player: familyPlayers[ranked[k]],
                        teamName: _teamName(l, _team[ranked[k]]!),
                        style: charadesTeams[_team[ranked[k]]!],
                        points: _points[ranked[k]] ?? 0,
                        star: top > 0 && (_points[ranked[k]] ?? 0) == top,
                        starLabel: l.charadesStarPlayer,
                        first: k == 0,
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
                child: _BigButton(
                  label: l.charadesBackToGames,
                  height: 54,
                  radius: 16,
                  background: Colors.white,
                  foreground: AC.ink,
                  border: AC.border,
                  weight: FontWeight.w700,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _BigButton(
                  label: l.charadesNewGame,
                  height: 54,
                  radius: 16,
                  background: AC.brick,
                  foreground: Colors.white,
                  onTap: _startGame,
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

class _RoundBack extends StatelessWidget {
  final VoidCallback onTap;
  const _RoundBack({required this.onTap});
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: MaterialLocalizations.of(context).backButtonTooltip,
    excludeSemantics: true,
    child: Material(
      color: Colors.white,
      shape: const CircleBorder(side: BorderSide(color: AC.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Icon(Icons.chevron_right_rounded, size: 24, color: AC.ink),
          ),
        ),
      ),
    ),
  );
}

class _TeamNameBox extends StatelessWidget {
  final TeamStyle style;
  final String label, count;
  final TextEditingController controller;
  final VoidCallback onChanged;
  const _TeamNameBox({
    required this.style,
    required this.label,
    required this.count,
    required this.controller,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: style.tint,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: style.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: style.ink,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: TextField(
            controller: controller,
            maxLength: 14,
            onChanged: (_) => onChanged(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: style.ink,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: style.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: style.color, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(count, style: TextStyle(fontSize: 12, color: style.ink)),
      ],
    ),
  );
}

class _PlayerRow extends StatelessWidget {
  final FamilyPlayer player;
  final int? team;
  final String shortA, shortB, groupLabel;
  final bool first;
  final ValueChanged<int> onPick;
  const _PlayerRow({
    required this.player,
    required this.team,
    required this.shortA,
    required this.shortB,
    required this.groupLabel,
    required this.first,
    required this.onPick,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      border: first ? null : const Border(top: BorderSide(color: AC.track)),
    ),
    child: Row(
      children: [
        PlayerAvatar(player: player, size: 34, opacity: team == null ? .45 : 1),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            player.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AC.ink,
            ),
          ),
        ),
        Semantics(
          container: true,
          label: groupLabel,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: AC.track,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _TeamSeg(
                  label: shortA,
                  color: charadesTeams[0].color,
                  on: team == 0,
                  onTap: () => onPick(0),
                ),
                const SizedBox(width: 4),
                _TeamSeg(
                  label: shortB,
                  color: charadesTeams[1].color,
                  on: team == 1,
                  onTap: () => onPick(1),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _TeamSeg extends StatelessWidget {
  final String label;
  final Color color;
  final bool on;
  final VoidCallback onTap;
  const _TeamSeg({
    required this.label,
    required this.color,
    required this.on,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: on,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      // 44 high hit area around the visual segment.
      child: Container(
        height: 44,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 36,
          constraints: const BoxConstraints(minWidth: 52),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: on ? Colors.white : AC.muted,
            ),
          ),
        ),
      ),
    ),
  );
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Segment({
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
      // 44 high hit area around the visual segment.
      child: Container(
        height: 44,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: AC.cardShadow,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

class _BigButton extends StatelessWidget {
  final String label;
  final double height, radius, fontSize;
  final Color background, foreground;
  final Color? border;
  final Widget? leading, trailing;
  final bool shadow;
  final FontWeight weight;
  final VoidCallback? onTap;
  const _BigButton({
    required this.label,
    required this.height,
    required this.radius,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.border,
    this.leading,
    this.trailing,
    this.shadow = false,
    this.fontSize = 16,
    this.weight = FontWeight.w800,
  });
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      boxShadow: shadow
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
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: border == null ? BorderSide.none : BorderSide(color: border!),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 8)],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: weight,
                    color: foreground,
                  ),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 10), trailing!],
            ],
          ),
        ),
      ),
    ),
  );
}

class _EndGameOutline extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color, border;
  final Color? background;
  final double height;
  final bool fill;
  const _EndGameOutline({
    this.background,
    required this.label,
    required this.onTap,
    required this.color,
    required this.border,
    required this.height,
    this.fill = false,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: background ?? Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: border),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisSize: fill ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stop_rounded, size: 16, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _HandoffScore extends StatelessWidget {
  final String name;
  final int score;
  const _HandoffScore({required this.name, required this.score});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .14),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 110),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: .85),
            ),
          ),
        ),
        Text(
          '$score',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}

class _RevealButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _RevealButton({super.key, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
    color: AC.background,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedRRect(const Color(0xFFD9C6AE)),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.visibility_outlined, size: 20, color: AC.ink),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AC.ink,
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

class _DashedRRect extends CustomPainter {
  final Color color;
  const _DashedRRect(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 10) {
        canvas.drawPath(m.extractPath(d, d + 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRect old) => old.color != color;
}

class _RankRow extends StatelessWidget {
  final FamilyPlayer player;
  final String teamName;
  final TeamStyle style;
  final int points;
  final bool star, first;
  final String starLabel;
  const _RankRow({
    required this.player,
    required this.teamName,
    required this.style,
    required this.points,
    required this.star,
    required this.first,
    required this.starLabel,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      border: first ? null : const Border(top: BorderSide(color: AC.track)),
    ),
    child: Row(
      children: [
        PlayerAvatar(player: player, size: 30),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            player.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AC.ink,
            ),
          ),
        ),
        if (star) ...[
          _Tag(
            label: starLabel,
            bg: AC.mustardTint,
            fg: const Color(0xFF5A4E36),
          ),
          const SizedBox(width: 6),
        ],
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 80),
          child: _Tag(label: teamName, bg: style.tint, fg: style.ink),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 24,
          child: Text(
            '$points',
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AC.ink,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Tag extends StatelessWidget {
  final String label;
  final Color bg, fg;
  const _Tag({required this.label, required this.bg, required this.fg});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
    ),
  );
}

class _CrownPainter extends CustomPainter {
  const _CrownPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 64, size.height / 52);
    final p = Paint()..color = AC.mustard;
    final crown = Path()
      ..moveTo(6, 44)
      ..lineTo(2, 12)
      ..lineTo(18, 24)
      ..lineTo(32, 4)
      ..lineTo(46, 24)
      ..lineTo(62, 12)
      ..lineTo(58, 44)
      ..close();
    canvas.drawPath(crown, p);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(6, 44, 52, 8),
        const Radius.circular(3),
      ),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant _CrownPainter old) => false;
}
