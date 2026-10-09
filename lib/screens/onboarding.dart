import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data.dart';
import '../l10n/app_localizations.dart';
import '../l10n/data_localizations.dart';
import '../theme.dart';
import '../widgets.dart';

enum _Step { splash, about, interests, signup, family, character }

const _jobs = <(String, String, Color)>[
  ('I work', 'Working', C.tealTint),
  ("I'm a student", 'Student', C.mustardTint),
  ('I stay at home', 'Stays at home', C.coralTint),
];
/// (key, label, default character index)
const _roles = <(String, String, int)>[
  ('mom', 'Mom', 3),
  ('dad', 'Dad', 2),
  ('daughter', 'Daughter', 0),
  ('brother', 'Son', 1),
];
const _interests = [
  'Coffee', 'Games', 'Reading', 'Walking', 'Podcasts', 'Movies',
  'Cooking', 'Drawing', 'Football', 'Swimming', 'Music', 'Travel',
];
const _outingTypes = ['Nature', 'Restaurants', 'Cafés', 'Entertainment'];

String _jobLabel(AppLocalizations l, String key) => switch (key) {
      'I work' => l.onboardingJobWork,
      "I'm a student" => l.onboardingJobStudent,
      'I stay at home' => l.onboardingJobHome,
      _ => key,
    };

String _roleLabel(AppLocalizations l, String key) => switch (key) {
      'mom' => l.roleMomLabel,
      'dad' => l.roleDadLabel,
      'daughter' => l.roleDaughterLabel,
      'brother' => l.roleSonLabel,
      _ => key,
    };

/// 01 Splash -> 02 questionnaire -> 03 sign up -> 04 create/join family -> pick a character.
class OnboardingFlow extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingFlow({super.key, required this.onDone});
  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  _Step _step = _Step.splash;
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _family = TextEditingController();
  final _code = TextEditingController();
  final _ageCtrl = TextEditingController();
  int get _age => int.tryParse(_ageCtrl.text) ?? 0;
  String? _job;
  String? _role;
  final _picked = <String>{};
  final _outings = <String>{};
  String? _prefer;
  int _avatar = 0;

  void _go(_Step s) => setState(() => _step = s);
  void _back() => setState(() => _step = _Step.values[_step.index - 1]);

  bool get _canNext => switch (_step) {
        _Step.about => _name.text.trim().isNotEmpty && _role != null && _age >= 3 && _age <= 110 && _job != null,
        _Step.interests => _picked.isNotEmpty,
        _Step.signup => _phone.text.trim().length >= 9,
        _ => true,
      };

  void _finish({required bool joined}) {
    profile
      ..phone = _phone.text.trim()
      ..family = joined || _family.text.trim().isEmpty ? 'Your family' : _family.text.trim()
      ..name = _name.text.trim()
      ..age = _age
      ..job = _jobs.firstWhere((j) => j.$1 == _job).$2
      ..interests = {..._picked}
      ..outingTypes = {..._outings}
      ..prefer = _prefer ?? 'Games'
      ..role = _role!
      ..avatar = _avatar;
    // take over the family slot that matches the chosen role
    final i = members.indexWhere((m) => m.key == _role);
    members[i] = Member(_role!, profile.name, _roles.firstWhere((r) => r.$1 == _role).$2, _age,
        characters[_avatar].$2, 0);
    seedSample();
    widget.onDone();
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _family, _code, _ageCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
        body: SafeArea(
          child: switch (_step) {
            _Step.splash => _splash(l),
            _Step.about => _page(l, l.onboardingAboutTitle, l.onboardingAboutSubtitle, _about(l), l.onboardingNext,
                () => _go(_Step.interests)),
            _Step.interests => _page(l, l.onboardingInterestsTitle, l.onboardingInterestsSubtitle,
                _interestsBody(l), l.onboardingNext, () => _go(_Step.signup)),
            _Step.signup => _page(l, l.onboardingSignupTitle, l.onboardingSignupSubtitle, _signup(l),
                l.onboardingCreateAccount, () => _go(_Step.family)),
            _Step.family => _page(l, l.onboardingFamilyTitle, l.onboardingFamilySubtitle, _familyBody(l), null, null),
            _Step.character => _page(l, l.onboardingCharacterTitle, l.onboardingCharacterSubtitle,
                _characterBody(l), l.onboardingLetsGo, () => _finish(joined: _code.text.trim().isNotEmpty)),
          },
        ),
      );
  }

  // ---- 01 splash
  Widget _splash(AppLocalizations l) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.asset(familyScene, height: 230, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 28),
          Text(l.onboardingSplashLogo,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: C.terracotta)),
          const SizedBox(height: 6),
          Text(l.onboardingSplashTagline, style: const TextStyle(fontSize: 18, color: C.inkSoft)),
          const Spacer(),
          Builder(builder: (context) {
            final rtl = Directionality.of(context) == TextDirection.rtl;
            return Btn(l.onboardingSplashStart,
                icon: rtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                onTap: () => _go(_Step.about));
          }),
        ]),
      );

  // ---- shared step scaffold
  Widget _page(AppLocalizations l, String title, String sub, Widget body, String? cta, VoidCallback? onCta) =>
      Column(children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 24, 0),
          child: Row(children: [
            Builder(builder: (context) {
              final rtl = Directionality.of(context) == TextDirection.rtl;
              return IconButton(
                  onPressed: _back,
                  icon: Icon(rtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded));
            }),
            Expanded(child: Bar((_step.index) / (_Step.values.length - 1))),
          ]),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 20, 24, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, height: 1.2)),
              const SizedBox(height: 6),
              Text(sub, style: const TextStyle(color: C.inkSoft, fontSize: 15)),
              const SizedBox(height: 24),
              body,
            ]),
          ),
        ),
        if (cta != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 16),
            child: Btn(cta, enabled: _canNext, onTap: onCta),
          ),
      ]);

  // ---- 02a about you
  Widget _about(AppLocalizations l) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Field(l.onboardingNameLabel,
            hint: l.onboardingNameHint, controller: _name, onChanged: (_) => setState(() {})),
        Field(l.onboardingAgeLabel,
            hint: l.onboardingAgeHint,
            controller: _ageCtrl,
            keyboard: TextInputType.number,
            formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
            onChanged: (_) => setState(() {})),
        Text(l.onboardingRoleQuestion, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final r in _roles)
            Choice(_roleLabel(l, r.$1), _role == r.$1, () => setState(() {
                  _role = r.$1;
                  _avatar = r.$3;
                })),
        ]),
        const SizedBox(height: 16),
        Text(l.onboardingJobQuestion, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        for (final j in _jobs)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: LCard(
              color: _job == j.$1 ? j.$3 : null,
              onTap: () => setState(() => _job = j.$1),
              child: Row(children: [
                Expanded(child: Text(_jobLabel(l, j.$1), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
                if (_job == j.$1) const Icon(Icons.check_circle_rounded, color: C.terracotta),
              ]),
            ),
          ),
      ]);

  // ---- 02b interests
  Widget _interestsBody(AppLocalizations l) => Builder(builder: (context) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.onboardingThingsYouLove, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final h in _interests)
              Choice(ld(context, h), _picked.contains(h),
                  () => setState(() => _picked.contains(h) ? _picked.remove(h) : _picked.add(h))),
          ]),
          const SizedBox(height: 24),
          Text(l.onboardingTypeOfOutings, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final h in _outingTypes)
              Choice(ld(context, h), _outings.contains(h),
                  () => setState(() => _outings.contains(h) ? _outings.remove(h) : _outings.add(h))),
          ]),
          const SizedBox(height: 24),
          Text(l.onboardingIPrefer, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Row(children: [
            for (final p in ['Games', 'Discussions']) ...[
              Expanded(
                child: LCard(
                  color: _prefer == p ? C.navy : null,
                  onTap: () => setState(() => _prefer = p),
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  child: Center(
                      child: Text(p == 'Games' ? l.onboardingPreferGames : l.onboardingPreferDiscussions,
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: _prefer == p ? Colors.white : C.ink))),
                ),
              ),
              if (p == 'Games') const SizedBox(width: 12),
            ],
          ]),
        ]);
      });

  // ---- 03 sign up
  Widget _signup(AppLocalizations l) => Column(children: [
        Field('', hint: l.onboardingPhoneHint, icon: Icons.phone_rounded,
            controller: _phone, keyboard: TextInputType.phone, onChanged: (_) => setState(() {})),
        const SizedBox(height: 4),
        TextButton(
            onPressed: () => _go(_Step.family),
            child: Text(l.onboardingSigninInstead,
                style: const TextStyle(color: C.inkSoft, fontWeight: FontWeight.w700))),
      ]);

  // ---- 04 family
  Widget _familyBody(AppLocalizations l) => Column(children: [
        LCard(
          color: C.navy,
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Text(l.onboardingStartFamily,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            TextField(
              controller: _family,
              decoration: InputDecoration(hintText: l.onboardingFamilyNameHint),
            ),
            const SizedBox(height: 12),
            Btn(l.onboardingCreate, color: C.terracotta, onTap: () {
              _code.clear();
              _go(_Step.character);
            }),
          ]),
        ),
        const SizedBox(height: 16),
        LCard(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.onboardingHaveInviteCode,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            TextField(
              controller: _code,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(hintText: l.onboardingInviteCodeHint),
            ),
            const SizedBox(height: 12),
            Btn(l.onboardingJoin, outlined: true, onTap: () {
              if (_code.text.trim().isEmpty) return;
              _go(_Step.character);
            }),
          ]),
        ),
      ]);

  // ---- character
  Widget _characterBody(AppLocalizations l) => Builder(builder: (context) {
        return Column(children: [
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 5)),
              child: ClipOval(
                  child: Image.asset(characters[_avatar].$2, fit: BoxFit.cover, alignment: Alignment.topCenter)),
            ),
          ),
          const SizedBox(height: 8),
          Text(ld(context, characters[_avatar].$1), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            children: [
              for (var i = 0; i < characters.length; i++)
                GestureDetector(
                  onTap: () => setState(() => _avatar = i),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _avatar == i ? C.terracotta : Colors.transparent, width: 3),
                    ),
                    child: ClipOval(
                        child: Image.asset(characters[i].$2, fit: BoxFit.cover, alignment: Alignment.topCenter)),
                  ),
                ),
            ],
          ),
        ]);
      });
}
