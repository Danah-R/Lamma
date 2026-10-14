import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../backend/backend.dart';
import '../data.dart';
import '../l10n/app_localizations.dart';
import '../l10n/data_localizations.dart';
import '../theme.dart';
import '../widgets.dart' show FaceImage;
import '../widgets/form_controls.dart';

enum _Step { about, interests, family, character }

const _jobs = <(String, String, Color)>[
  ('I work', 'Working', C.tealTint),
  ("I'm a student", 'Student', C.yellowTint),
  ('I stay at home', 'Stays at home', C.peachTint),
];

/// (key, label, default character index)
const _roles = <(String, String, int)>[
  ('mom', 'Mom', 3),
  ('dad', 'Dad', 2),
  ('daughter', 'Daughter', 0),
  ('brother', 'Son', 1),
  ('other', 'Other', 0), // their own role, typed in
];

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
  'other' => l.roleOtherLabel,
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
  _Step _step = _Step.about;
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _family = TextEditingController();
  final _code = TextEditingController();
  final _ageCtrl = TextEditingController();
  int get _age => int.tryParse(_ageCtrl.text) ?? 0;
  String? _nick; // optional display name chosen on the character step
  String get _displayName => (_nick == null || _nick!.trim().isEmpty)
      ? _name.text.trim()
      : _nick!.trim();
  bool _noPhone = false; // joining a family without a phone number
  String? _job;
  bool? _livesWithFamily;
  String? _role;
  final _otherRole = TextEditingController(); // used when the role is "Other"
  final _picked = <String>{};
  final _outings = <String>{};
  String? _prefer;
  int _avatar = 0;

  void _go(_Step s) => setState(() => _step = s);
  void _back() {
    if (_step.index > 0) setState(() => _step = _Step.values[_step.index - 1]);
  }

  bool get _canNext => switch (_step) {
    _Step.about =>
      _name.text.trim().isNotEmpty &&
          _role != null &&
          (_role != 'other' || _otherRole.text.trim().isNotEmpty) &&
          _age >= 3 &&
          _age <= 110 &&
          _job != null &&
          _livesWithFamily != null &&
          (_noPhone || _phone.text.trim().length >= 9),
    _Step.interests => _picked.isNotEmpty,
    _ => true,
  };

  bool _busy = false; // talking to the database
  String? _joinError; // shown under the invite code field

  String _errorText(AppLocalizations l, BackendException e) => switch (e.kind) {
    BackendError.invalidCode => l.onboardingErrInvalidCode,
    BackendError.tooManyAttempts => l.onboardingErrTooMany,
    _ => l.onboardingErrNetwork,
  };

  /// Joining: check the code as soon as it is entered, before the rest of onboarding.
  Future<void> _checkCode() async {
    if (_code.text.trim().isEmpty) return;
    if (!Backend.enabled) return _go(_Step.character);
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _joinError = null;
    });
    try {
      await Backend.checkJoinCode(_code.text);
      if (!mounted) return;
      setState(() => _busy = false);
      _go(_Step.character);
    } on BackendException catch (e) {
      if (mounted)
        setState(() {
          _busy = false;
          _joinError = _errorText(l, e);
        });
    }
  }

  /// Creates or joins the family in the database, then enters the app.
  Future<void> _finish({required bool joined}) async {
    if (!Backend.enabled) return _finishLocal(joined: joined);
    if (_busy) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final pj = Backend.profileJson(
        name: _displayName,
        role: _role!,
        roleLabel: _role == 'other' ? _otherRole.text.trim() : null,
        age: _age,
        job: _jobs.firstWhere((j) => j.$1 == _job).$2,
        livesWithFamily: _livesWithFamily ?? true,
        phone: _noPhone ? null : _phone.text.trim(),
        interests: _picked,
        outingTypes: _outings,
        prefer: _prefer ?? 'Games',
        avatar: _avatar,
      );
      if (joined) {
        await Backend.joinFamily(_code.text.trim(), pj);
      } else {
        await Backend.createFamily(
          _family.text.trim().isEmpty ? 'Your family' : _family.text.trim(),
          pj,
        );
      }
      seedSample();
      widget.onDone();
    } on BackendException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      if (e.kind == BackendError.alreadyInFamily &&
          await Backend.loadFamily()) {
        seedSample();
        widget.onDone();
      } else if (e.kind == BackendError.invalidCode ||
          e.kind == BackendError.tooManyAttempts) {
        setState(() => _joinError = _errorText(l, e));
        _go(_Step.family);
      } else {
        debugPrint('Finishing onboarding failed: $e');
        messenger.showSnackBar(SnackBar(content: Text(_errorText(l, e))));
      }
    } catch (e) {
      // anything unexpected: stay on the page and let the person try again
      debugPrint('Finishing onboarding failed unexpectedly: $e');
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text(l.onboardingErrNetwork)));
    }
  }

  /// Offline (and in tests): keep everything on the phone with the sample family.
  void _finishLocal({required bool joined}) {
    profile
      ..phone = _phone.text.trim()
      ..family = joined || _family.text.trim().isEmpty
          ? 'Your family'
          : _family.text.trim()
      ..name = _displayName
      ..age = _age
      ..livesWithFamily = _livesWithFamily ?? true
      ..job = _jobs.firstWhere((j) => j.$1 == _job).$2
      ..interests = {..._picked}
      ..outingTypes = {..._outings}
      ..prefer = _prefer ?? 'Games'
      ..role = _role == 'other' ? 'brother' : _role!
      ..avatar = _avatar;
    // take over the family slot that matches the chosen role
    final slot = _role == 'other'
        ? 'brother'
        : _role; // "other" takes a non-parent slot
    final roleText = _role == 'other'
        ? _otherRole.text.trim()
        : _roles.firstWhere((r) => r.$1 == _role).$2;
    final i = members.indexWhere((m) => m.key == slot);
    members[i] = Member(
      slot!,
      profile.name,
      roleText,
      _age,
      characters[_avatar].$2,
      0,
    );
    seedSample();
    widget.onDone();
  }

  @override
  void dispose() {
    _nickCtl.dispose();
    _nickFocus.dispose();
    for (final c in [_name, _phone, _family, _code, _ageCtrl, _otherRole]) {
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
          _Step.about => _page(
            l,
            l.onboardingAboutTitle,
            l.onboardingAboutSubtitle,
            _about(l),
            l.onboardingNext,
            () => _go(_Step.interests),
            footer: _signInLink(l),
          ),
          _Step.interests => _page(
            l,
            l.onboardingInterestsTitle,
            l.onboardingInterestsSubtitle,
            kInterestsBody(l),
            l.onboardingNext,
            () => _go(_Step.family),
          ),
          _Step.family => _page(
            l,
            l.onboardingFamilyTitle,
            l.onboardingFamilySubtitle,
            _familyBody(l),
            null,
            null,
          ),
          _Step.character => _page(
            l,
            l.onboardingCharacterTitle,
            l.onboardingCharacterSubtitle,
            _characterBody(l),
            l.onboardingLetsGo,
            () => _finish(joined: _code.text.trim().isNotEmpty),
          ),
        },
      ),
    );
  }

  // ---- shared step scaffold
  Widget _page(
    AppLocalizations l,
    String title,
    String sub,
    Widget body,
    String? cta,
    VoidCallback? onCta, {
    Widget? footer,
  }) => Column(
    children: [
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          FormStyle.margin,
          14,
          FormStyle.margin,
          0,
        ),
        child: _StepBar(current: _step.index, total: _Step.values.length),
      ),
      Expanded(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsetsDirectional.fromSTEB(
            FormStyle.margin,
            28,
            FormStyle.margin,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: FormStyle.title),
              const SizedBox(height: 8),
              Text(sub, style: FormStyle.subtitle),
              const SizedBox(height: 28),
              body,
            ],
          ),
        ),
      ),
      if (footer != null)
        Padding(padding: const EdgeInsets.only(bottom: 8), child: footer),
      // back and forward, centered: each is an arrow together with a word. Both stay on
      // screen (dimmed when unavailable) so the pair never shifts.
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          FormStyle.margin,
          0,
          FormStyle.margin,
          20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: _NavButton(
                key: const Key('onboarding-back'),
                label: l.onboardingBack,
                icon: Icons.arrow_back_rounded, // Material arrows mirror themselves in right-to-left
                arrowFirst: true,
                enabled: _step.index > 0,
                onTap: _back,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: _NavButton(
                key: const Key('onboarding-next'),
                label: cta ?? l.onboardingNext,
                icon: Icons.arrow_forward_rounded,
                arrowFirst: false,
                filled: true,
                enabled: cta != null && _canNext && !_busy,
                onTap: onCta,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  // ---- 02a about you
  Widget _about(AppLocalizations l) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FormTextField(
        label: l.onboardingNameLabel,
        hint: l.onboardingNameHint,
        controller: _name,
        textCapitalization: TextCapitalization.words,
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 20),
      FormTextField(
        label: l.onboardingAgeLabel,
        hint: l.onboardingAgeHint,
        controller: _ageCtrl,
        keyboard: TextInputType.number,
        formatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 28),
      FormSection(
        l.onboardingRoleQuestion,
        SegmentedChoice(
          options: [for (final r in _roles) (r.$1, _roleLabel(l, r.$1))],
          selected: _role,
          track: C.peachTint,
          on: C.brick,
          onChanged: (k) => setState(() {
            _role = k;
            _avatar = _roles.firstWhere((r) => r.$1 == k).$3;
          }),
        ),
      ),
      if (_role == 'other') ...[
        const SizedBox(height: 12),
        FormTextField(
          hint: l.onboardingOtherRoleHint,
          controller: _otherRole,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}),
        ),
      ] else
        const SizedBox(height: 16),
      const SizedBox(height: 12),
      FormSection(
        l.onboardingJobQuestion,
        GroupedChoiceList(
          rows: [for (final j in _jobs) (j.$1, _jobLabel(l, j.$1))],
          selected: _job,
          highlight: C.peachTint,
          accent: C.brick,
          onTap: (k) => setState(() => _job = k),
        ),
      ),
      const SizedBox(height: 28),
      FormSection(
        l.onboardingLiveTogetherQuestion,
        SegmentedChoice(
          options: [('yes', l.onboardingYes), ('no', l.onboardingNo)],
          selected: _livesWithFamily == null
              ? null
              : (_livesWithFamily! ? 'yes' : 'no'),
          onChanged: (k) => setState(() => _livesWithFamily = k == 'yes'),
          track: C.peachTint,
          on: C.brick,
        ),
      ),
      const SizedBox(height: 28),
      // last question: the phone number, with the way out right under it
      Opacity(
        opacity: _noPhone ? .4 : 1,
        child: IgnorePointer(
          ignoring: _noPhone,
          child: FormTextField(
            label: l.onboardingPhoneLabel,
            hint: l.onboardingPhoneHint,
            icon: Icons.phone_outlined,
            controller: _phone,
            keyboard: TextInputType.phone,
            textDirection: TextDirection.ltr,
            onChanged: (_) => setState(() {}),
          ),
        ),
      ),
      InkWell(
        onTap: () => setState(() {
          _noPhone = !_noPhone;
          if (_noPhone) _phone.clear();
        }),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: RadioDot(_noPhone),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.onboardingNoPhone,
                  style: const TextStyle(
                    color: C.teal,
                    fontSize: 15,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  // ---- 02b interests
  Widget kInterestsBody(AppLocalizations l) => Builder(
    builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSection(
            l.onboardingThingsYouLove,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final h in kInterests)
                  ChoiceTag(
                    ld(context, h),
                    _picked.contains(h),
                    () => setState(
                      () => _picked.contains(h)
                          ? _picked.remove(h)
                          : _picked.add(h),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          FormSection(
            l.onboardingTypeOfOutings,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final h in kOutingTypes)
                  ChoiceTag(
                    ld(context, h),
                    _outings.contains(h),
                    () => setState(
                      () => _outings.contains(h)
                          ? _outings.remove(h)
                          : _outings.add(h),
                    ),
                    idle: C.peachTint,
                    on: C.brick,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          FormSection(
            l.onboardingIPrefer,
            Row(
              children: [
                Expanded(
                  child: ChoiceCard(
                    l.onboardingPreferDiscussions,
                    _prefer == 'Discussions',
                    () => setState(() => _prefer = 'Discussions'),
                    icon: Image.asset('assets/icons/prefer_discussions.png'),
                    tint: C.sageTint,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceCard(
                    l.onboardingPreferGames,
                    _prefer == 'Games',
                    () => setState(() => _prefer = 'Games'),
                    icon: Image.asset('assets/icons/prefer_games.png'),
                    tint: C.yellowTint,
                    iconSize: 108,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );

  /// "I already have an account", at the bottom of the first page.
  Widget _signInLink(AppLocalizations l) => Center(
    child: TextButton(
      onPressed: () => _go(_Step.family),
      child: Text(
        l.onboardingSigninInstead,
        style: const TextStyle(
          color: C.brick,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );

  // ---- 04 family
  Widget _familyBody(AppLocalizations l) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // creating a family needs an account with a phone number; joining does not
      if (!_noPhone) ...[
        FormTextField(
          label: l.onboardingStartFamily,
          hint: l.onboardingFamilyNameHint,
          controller: _family,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 12),
        ActionButton(
          l.onboardingCreate,
          onTap: () {
            _code.clear();
            _go(_Step.character);
          },
        ),
        const SizedBox(height: 36),
      ],
      FormTextField(
        label: l.onboardingHaveInviteCode,
        hint: l.onboardingInviteCodeHint,
        controller: _code,
        textCapitalization: TextCapitalization.characters,
        onChanged: (_) {
          if (_joinError != null) setState(() => _joinError = null);
        },
      ),
      if (_joinError != null)
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
          child: Text(
            _joinError!,
            style: const TextStyle(color: C.brick, fontSize: 14, height: 1.3),
          ),
        ),
      const SizedBox(height: 12),
      ActionButton(
        l.onboardingJoin,
        tinted: true,
        onTap: _busy ? () {} : _checkCode,
      ),
    ],
  );

  bool _editingName = false;
  final _nickCtl = TextEditingController();
  final _nickFocus = FocusNode();

  void _startEditName() {
    _nickCtl.text = _displayName;
    _nickCtl.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _nickCtl.text.length,
    );
    setState(() => _editingName = true);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _nickFocus.requestFocus(),
    );
  }

  void _cancelEditName() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _editingName = false); // discards what was typed
  }

  final _nickGroup = Object();

  void _finishEditName() {
    final v = _nickCtl.text.trim();
    setState(() {
      if (v.isNotEmpty) _nick = v;
      _editingName = false;
    });
  }

  // ---- character
  Widget _characterBody(AppLocalizations l) => Builder(
    builder: (context) {
      return Column(
        children: [
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: ClipOval(child: FaceImage(characters[_avatar].$2)),
            ),
          ),
          const SizedBox(height: 10),
          // the user's own name; the pencil edits it right here (e.g. a nickname)
          SizedBox(
            height: 40,
            child: _editingName
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IntrinsicWidth(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 80,
                            maxWidth: 220,
                          ),
                          child: TextField(
                            controller: _nickCtl,
                            focusNode: _nickFocus,
                            groupId: _nickGroup,
                            onTapOutside: (_) => _cancelEditName(),
                            textAlign: TextAlign.center,
                            textCapitalization: TextCapitalization.words,
                            cursorColor: C.brick,
                            style: FormStyle.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: const InputDecoration.collapsed(
                              hintText: '',
                            ),
                            onSubmitted: (_) => _finishEditName(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TapRegion(
                        groupId: _nickGroup, // tapping the check counts as inside, so it saves instead of cancelling
                        child: GestureDetector(
                          onTap: _finishEditName,
                          child: const Icon(
                            Icons.check_rounded,
                            size: 22,
                            color: C.teal,
                          ),
                        ),
                      ),
                    ],
                  )
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _startEditName,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            _displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FormStyle.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: C.inkSoft,
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 28),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 18,
            runSpacing: 18,
            children: [
              for (var i = 0; i < characters.length; i++)
                GestureDetector(
                  onTap: () => setState(() => _avatar = i),
                  child: Container(
                    width: 78,
                    height: 78,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _avatar == i ? C.brick : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: ClipOval(child: FaceImage(characters[i].$2)),
                  ),
                ),
            ],
          ),
        ],
      );
    },
  );
}

/// Numbered rounded squares joined by a line. The current step is filled,
/// finished steps are tinted, and later steps are plain.
class _StepBar extends StatelessWidget {
  final int current, total;
  const _StepBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 0; i < total; i++) ...[
        if (i > 0)
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                // quiet: a soft tint, a little stronger once that step is reached
                color: i <= current ? C.brick.withValues(alpha: .28) : C.line,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        _StepSquare(
          number: i + 1,
          state: i == current ? 2 : (i < current ? 1 : 0),
        ),
      ],
    ],
  );
}

class _StepSquare extends StatelessWidget {
  final int number;
  final int state; // 0 upcoming, 1 done, 2 current
  const _StepSquare({required this.number, required this.state});

  @override
  Widget build(BuildContext context) {
    final current = state == 2, done = state == 1;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: current ? C.brick : (done ? C.brickTint : C.card),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        '$number',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: current ? Colors.white : (done ? C.brick : C.inkSoft),
        ),
      ),
    );
  }
}

/// Pill button with an arrow and a word.
class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool arrowFirst, filled, enabled;
  final VoidCallback? onTap;
  const _NavButton({
    super.key,
    required this.label,
    required this.icon,
    required this.arrowFirst,
    this.filled = false,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = !filled ? C.card : (enabled ? C.brick : C.sand);
    final fg = !filled ? C.ink : (enabled ? Colors.white : C.inkSoft);
    final arrow = Icon(icon, color: fg, size: 20);
    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: fg),
    );
    return Opacity(
      // a disabled back button fades out; the forward one keeps its tan "not yet" fill
      opacity: !filled && !enabled ? .35 : 1,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: enabled ? onTap : null,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (arrowFirst) ...[
                  arrow,
                  const SizedBox(width: 8),
                  Flexible(child: text),
                ] else ...[
                  Flexible(child: text),
                  const SizedBox(width: 8),
                  arrow,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
