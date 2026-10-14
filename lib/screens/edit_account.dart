import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../backend/backend.dart';
import '../data.dart';
import '../l10n/app_localizations.dart';
import '../l10n/data_localizations.dart';
import '../theme.dart';
import '../widgets.dart';
import '../widgets/form_controls.dart';

/// "Edit your account": everything entered while creating the account, in one place.
/// The family role itself is fixed (it decides who is a parent), but an "Other" role's
/// wording can be changed.
class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key});
  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  late final _name = TextEditingController(text: profile.name);
  late final _age = TextEditingController(text: '${profile.age}');
  late final _phone = TextEditingController(text: profile.phone);
  late final _roleLabel = TextEditingController(text: _myMember?.role ?? '');
  late String _job = profile.job;
  late bool _lives = profile.livesWithFamily;
  late final Set<String> _interests = {...profile.interests};
  late final Set<String> _outings = {...profile.outingTypes};
  late String _prefer = profile.prefer;
  late int _avatar = profile.avatar;
  bool _saving = false;

  Member? get _myMember {
    for (final m in members) {
      if (m.id != null ? m.id == profile.memberId : m.name == profile.name)
        return m;
    }
    return null;
  }

  bool get _isOther => profile.role == 'other';
  int get _ageValue => int.tryParse(_age.text) ?? 0;
  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      _ageValue >= 3 &&
      _ageValue <= 110 &&
      (!_isOther || _roleLabel.text.trim().isNotEmpty);

  @override
  void initState() {
    super.initState();
    if (Backend.enabled && profile.memberId != null) {
      Backend.loadMyPhone()
          .then((p) {
            if (mounted && p != null) setState(() => _phone.text = p);
          })
          .catchError((Object e) => debugPrint('Loading phone failed: $e'));
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _age, _phone, _roleLabel]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() => _saving = true);
    try {
      if (Backend.enabled && profile.memberId != null) {
        await Backend.updateMyProfile({
          'display_name': _name.text.trim(),
          if (_isOther) 'role_label': _roleLabel.text.trim(),
          'age': _ageValue,
          'job': _job,
          'lives_with_family': _lives,
          'interests': _interests.toList(),
          'outing_types': _outings.toList(),
          'prefer': _prefer,
          'avatar': _avatar,
        });
        await Backend.saveMyPhone(_phone.text);
      }
      final old = _myMember;
      profile
        ..name = _name.text.trim()
        ..age = _ageValue
        ..job = _job
        ..livesWithFamily = _lives
        ..interests = {..._interests}
        ..outingTypes = {..._outings}
        ..prefer = _prefer
        ..avatar = _avatar
        ..phone = _phone.text.trim();
      if (old != null) {
        final i = members.indexOf(old);
        members[i] = Member(
          old.key,
          profile.name,
          _isOther ? _roleLabel.text.trim() : old.role,
          profile.age,
          characters[_avatar].$2,
          old.points,
          id: old.id,
          parent: old.parent,
        );
      }
      nav.pop(true);
    } catch (e) {
      debugPrint('Saving the account failed: $e');
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(l.editAccountSaveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    void change(VoidCallback f) => setState(f);
    return Scaffold(
      appBar: AppBar(title: Text(l.editAccountTitle)),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsetsDirectional.fromSTEB(
          FormStyle.margin,
          8,
          FormStyle.margin,
          24,
        ),
        children: [
          // character
          FormSection(
            l.editAccountCharacter,
            Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: ClipOval(child: FaceImage(characters[_avatar].$2)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var i = 0; i < characters.length; i++)
                        GestureDetector(
                          onTap: () => change(() => _avatar = i),
                          child: Container(
                            width: 40,
                            height: 40,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _avatar == i
                                    ? C.brick
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(child: FaceImage(characters[i].$2)),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FormTextField(
            label: l.onboardingNameLabel,
            hint: l.onboardingNameHint,
            controller: _name,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => change(() {}),
          ),
          const SizedBox(height: 20),
          FormTextField(
            label: l.onboardingAgeLabel,
            hint: l.onboardingAgeHint,
            controller: _age,
            keyboard: TextInputType.number,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            onChanged: (_) => change(() {}),
          ),
          if (_isOther) ...[
            const SizedBox(height: 20),
            FormTextField(
              label: l.onboardingRoleQuestion,
              hint: l.onboardingOtherRoleHint,
              controller: _roleLabel,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => change(() {}),
            ),
          ],
          const SizedBox(height: 28),
          FormSection(
            l.onboardingJobQuestion,
            GroupedChoiceList(
              rows: [
                ('Working', l.onboardingJobWork),
                ('Student', l.onboardingJobStudent),
                ('Stays at home', l.onboardingJobHome),
              ],
              selected: _job,
              highlight: C.peachTint,
              accent: C.brick,
              onTap: (k) => change(() => _job = k),
            ),
          ),
          const SizedBox(height: 28),
          FormSection(
            l.onboardingLiveTogetherQuestion,
            SegmentedChoice(
              options: [('yes', l.onboardingYes), ('no', l.onboardingNo)],
              selected: _lives ? 'yes' : 'no',
              onChanged: (k) => change(() => _lives = k == 'yes'),
              track: C.peachTint,
              on: C.brick,
            ),
          ),
          const SizedBox(height: 28),
          FormTextField(
            label: l.onboardingPhoneLabel,
            hint: l.onboardingPhoneHint,
            icon: Icons.phone_outlined,
            controller: _phone,
            keyboard: TextInputType.phone,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 28),
          FormSection(
            l.onboardingThingsYouLove,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final h in kInterests)
                  ChoiceTag(
                    ld(context, h),
                    _interests.contains(h),
                    () => change(
                      () => _interests.contains(h)
                          ? _interests.remove(h)
                          : _interests.add(h),
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
                    () => change(
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
                    () => change(() => _prefer = 'Discussions'),
                    icon: Image.asset('assets/icons/prefer_discussions.png'),
                    tint: C.sageTint,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceCard(
                    l.onboardingPreferGames,
                    _prefer == 'Games',
                    () => change(() => _prefer = 'Games'),
                    icon: Image.asset('assets/icons/prefer_games.png'),
                    tint: C.yellowTint,
                    iconSize: 108,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            FormStyle.margin,
            8,
            FormStyle.margin,
            12,
          ),
          child: Btn(
            l.editAccountSave,
            enabled: _valid && !_saving,
            onTap: _save,
          ),
        ),
      ),
    );
  }
}
