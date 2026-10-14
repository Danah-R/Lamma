import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/data_localizations.dart';
import '../../theme.dart';
import '../../widgets.dart';
import '../../widgets/form_controls.dart';
import 'survey_controller.dart';
import 'survey_model.dart';

/// The monthly survey: who I got closest to, who I want to get closer to, what I enjoyed (and did not)
/// in the app, the outings and games I liked most, and how close I felt to my family.
class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});
  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final _a = SurveyAnswers();
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  /// Everyone in the family except me.
  List<String> get _others => [
    for (final m in members)
      if (profile.memberId != null
          ? m.id != profile.memberId
          : m.name != profile.name)
        m.name,
  ];

  String _feature(AppLocalizations l, String id) => switch (id) {
    'chat' => l.surveyFeatureChat,
    'moments' => l.surveyFeatureMoments,
    'games' => l.surveyFeatureGames,
    'podcast' => l.surveyFeaturePodcast,
    'book' => l.surveyFeatureBook,
    'topics' => l.surveyFeatureTopics,
    'outings' => l.surveyFeatureOutings,
    'calendar' => l.surveyFeatureCalendar,
    _ => l.surveyFeaturePoints,
  };

  String _game(AppLocalizations l, String id) => switch (id) {
    'whoami' => l.gamesWhoAmITitle,
    'charades' => l.gamesCharadesTitle,
    'seen' => l.gamesSinJimTitle,
    _ => l.gamesRouletteTitle,
  };

  /// A question: its text, a hint, and the choices as chips (several can be picked).
  Widget _multi(
    String question,
    List<(String, String)> options,
    Set<String> picked, {
    Color idle = C.peachTint,
    Color on = C.brick,
    bool withNone = false,
    String noneLabel = '',
  }) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: FormSection(
        question,
        options.isEmpty
            ? Text(l.surveyNoOthers, style: const TextStyle(color: C.inkSoft))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 4,
                      bottom: 10,
                    ),
                    child: Text(
                      l.surveyHintMulti,
                      style: const TextStyle(fontSize: 13, color: C.inkSoft),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final o in options)
                        ChoiceTag(
                          o.$2,
                          picked.contains(o.$1),
                          () => setState(() {
                            picked.remove(surveyNone);
                            if (!picked.add(o.$1)) picked.remove(o.$1);
                          }),
                          idle: idle,
                          on: on,
                        ),
                      if (withNone)
                        ChoiceTag(
                          noneLabel,
                          picked.contains(surveyNone),
                          () => setState(() {
                            final was = picked.contains(surveyNone);
                            picked.clear();
                            if (!was) picked.add(surveyNone);
                          }),
                          idle: C.line,
                          on: C.inkSoft,
                        ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _send() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    _a.comment = _comment.text;
    await context.read<SurveyController>().submit(_a);
    nav.pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.surveyThanks)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final people = [for (final n in _others) (n, ld(context, n))];
    return Page1(l.surveyTitle, [
      Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Text(
          l.surveyIntro,
          style: const TextStyle(fontSize: 15, height: 1.5, color: C.inkSoft),
        ),
      ),
      _multi(l.surveyQClosest, people, _a.closest),
      _multi(
        l.surveyQCloser,
        people,
        _a.wantCloser,
        idle: C.tealTint,
        on: C.teal,
      ),
      _multi(
        l.surveyQLiked,
        [for (final f in surveyFeatures) (f, _feature(l, f))],
        _a.liked,
        idle: C.sageTint,
        on: C.sageDark,
      ),
      _multi(
        l.surveyQDisliked,
        [for (final f in surveyFeatures) (f, _feature(l, f))],
        _a.disliked,
        idle: C.lavenderTint,
        on: C.navy,
      ),
      _multi(
        l.surveyQOutings,
        [for (final p in places) (p.name, ld(context, p.name))],
        _a.outings,
        idle: C.yellowTint,
        on: C.sageDark,
        withNone: true,
        noneLabel: l.surveyNothingThisMonth,
      ),
      _multi(
        l.surveyQGames,
        [for (final g in surveyGames) (g, _game(l, g))],
        _a.games,
        idle: C.tealTint,
        on: C.teal,
        withNone: true,
        noneLabel: l.surveyNothingThisMonth,
      ),
      // how close I felt: 1 to 5
      Padding(
        padding: const EdgeInsets.only(bottom: 26),
        child: FormSection(
          l.surveyQCloseness,
          Column(
            children: [
              Row(
                children: [
                  for (var i = 1; i <= 5; i++) ...[
                    if (i > 1) const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _a.closeness = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _a.closeness == i ? C.brick : C.peachTint,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '$i',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _a.closeness == i ? Colors.white : C.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l.surveyCloseLow,
                    style: const TextStyle(fontSize: 12, color: C.inkSoft),
                  ),
                  Text(
                    l.surveyCloseHigh,
                    style: const TextStyle(fontSize: 12, color: C.inkSoft),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      FormSection(
        l.surveyQComment,
        FormTextField(hint: l.surveyCommentHint, controller: _comment),
      ),
    ], bottom: ActionButton(l.surveySubmit, onTap: _send));
  }
}
