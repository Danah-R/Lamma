import 'package:flutter/material.dart';
import '../data.dart';
import '../l10n/app_localizations.dart';
import '../l10n/data_localizations.dart';
import '../theme.dart';
import '../widgets.dart';
import 'home.dart';

// ---- 12/15 Lamma tab: family talk + moments of our day
class LammaPage extends StatefulWidget {
  const LammaPage({super.key});
  @override
  State<LammaPage> createState() => _LammaPageState();
}

class _LammaPageState extends State<LammaPage> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
        body: ListView(padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 120), children: [
          TabHeader(l.navLamma, l.lammaSubtitle, onBell: () => go(context, const NotificationsPage())),
          SectionTitle(l.lammaFamilyTalk),
          for (final t in talks)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Avatar(t.who, size: 38),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(ld(context, t.who), style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text(ld(context, t.time), style: const TextStyle(color: C.inkSoft, fontSize: 12)),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Text(ld(context, t.text), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.4)),
                  const SizedBox(height: 12),
                  Row(children: [
                    GestureDetector(
                      onTap: () => setState(() => t.likes++),
                      child: Row(children: [
                        const Icon(Icons.favorite_border_rounded, size: 19, color: C.inkSoft),
                        const SizedBox(width: 5),
                        Text('${t.likes}', style: const TextStyle(color: C.inkSoft, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () => showComments(context),
                      child: Row(children: [
                        const Icon(Icons.chat_bubble_outline_rounded, size: 19, color: C.inkSoft),
                        const SizedBox(width: 5),
                        Text('${t.comments}', style: const TextStyle(color: C.inkSoft, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ]),
                ]),
              ),
            ),
          Btn(l.lammaOpenFamilyChat, color: C.navy, onTap: () => go(context, const FamilyChatPage())),
          SectionTitle(l.lammaMomentsOfOurDay,
              action: l.lammaShareMomentAction, onAction: () async {
            await go(context, const ShareMomentPage());
            if (mounted) setState(() {});
          }),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [for (final m in moments) _Box(m, () async {
              await go(context, MomentDetailsPage(m));
              if (mounted) setState(() {});
            })],
          ),
        ]),
      );
  }
}

/// Square photo box: only name and time show; the caption lives in the details.
class _Box extends StatelessWidget {
  final Moment m;
  final VoidCallback onTap;
  const _Box(this.m, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(fit: StackFit.expand, children: [
            PhotoBox(m.a, m.b),
            PositionedDirectional(
              start: 0,
              end: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 26, 12, 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [C.ink.withValues(alpha: 0), C.ink.withValues(alpha: .55)],
                  ),
                ),
                child: Row(children: [
                  Avatar(m.who, size: 26),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(ld(context, m.who),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                      Text(ld(context, m.time), style: const TextStyle(color: Colors.white70, fontSize: 10)),
                    ]),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      );
}

// ---- 16 open a moment
class MomentDetailsPage extends StatefulWidget {
  final Moment m;
  const MomentDetailsPage(this.m, {super.key});
  @override
  State<MomentDetailsPage> createState() => _MomentDetailsPageState();
}

class _MomentDetailsPageState extends State<MomentDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final m = widget.m;
    return Page1(l.momentTitle, [
      AspectRatio(
        aspectRatio: 1,
        child: PhotoBox(m.a, m.b, radius: 24, iconSize: 64),
      ),
      const SizedBox(height: 14),
      Row(children: [
        Avatar(m.who, size: 40),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ld(context, m.who), style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(ld(context, m.time), style: const TextStyle(color: C.inkSoft, fontSize: 12)),
          ]),
        ),
      ]),
      const SizedBox(height: 12),
      Text(ld(context, m.caption), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 16),
      Reactions(
        likes: m.likes,
        comments: m.comments,
        liked: m.liked,
        onLike: () => setState(() {
          m.liked = !m.liked;
          m.likes += m.liked ? 1 : -1;
        }),
        onComments: () => showComments(context),
      ),
    ]);
  }
}

// ---- 17 share a moment
class ShareMomentPage extends StatefulWidget {
  const ShareMomentPage({super.key});
  @override
  State<ShareMomentPage> createState() => _ShareMomentPageState();
}

class _ShareMomentPageState extends State<ShareMomentPage> {
  final _text = TextEditingController();
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tags = [l.shareMomentTagCafe, l.shareMomentTagWalking, l.shareMomentTagCooking];
    return Page1(l.shareMomentTitle, [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(color: C.beige, borderRadius: BorderRadius.circular(24)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.camera_alt_rounded, size: 44, color: C.terracotta),
              const SizedBox(height: 8),
              Text(l.shareMomentPhotoHint,
                  style: const TextStyle(color: C.inkSoft, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
        const SizedBox(height: 18),
        Field('', hint: l.shareMomentTextHint, controller: _text),
        Wrap(spacing: 8, children: [
          for (final s in tags)
            Choice(s, false, () => setState(() => _text.text = s), color: C.navy),
        ]),
      ],
          bottom: Btn(l.shareMomentSubmit, icon: Icons.send_rounded, onTap: () {
            moments.insert(
                0,
                Moment(profile.name, _text.text.trim().isEmpty ? l.shareMomentFallbackCaption : _text.text.trim(), 'Just now',
                    C.coral, C.coralTint, 0, 0));
            Navigator.pop(context);
          }));
  }
}

// ---- 13 family chat
class FamilyChatPage extends StatefulWidget {
  const FamilyChatPage({super.key});
  @override
  State<FamilyChatPage> createState() => _FamilyChatPageState();
}

class _FamilyChatPageState extends State<FamilyChatPage> {
  final _text = TextEditingController();
  final _msgs = <(String, String)>[
    ('Sarah', 'What are we cooking tonight?'),
    (profile.name, "Let's go to the park!"),
    ('Amina', 'Dinner will be ready soon'),
    (profile.name, 'Coming!'),
  ];

  void _send() {
    final t = _text.text.trim();
    if (t.isEmpty) return;
    setState(() => _msgs.add((profile.name, t)));
    _text.clear();
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
        appBar: AppBar(title: Text(l.familyChatTitle)),
        body: Column(children: [
          Expanded(
            child: ListView(padding: const EdgeInsets.all(20), children: [
              for (final m in _msgs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Align(
                    alignment: m.$1 == profile.name
                        ? AlignmentDirectional.centerEnd
                        : AlignmentDirectional.centerStart,
                    child: Column(
                      crossAxisAlignment:
                          m.$1 == profile.name ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (m.$1 != profile.name)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(start: 4, bottom: 2),
                            child: Text(ld(context, m.$1),
                                style: const TextStyle(fontSize: 11, color: C.inkSoft, fontWeight: FontWeight.w700)),
                          ),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 270),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                          decoration: BoxDecoration(
                            color: m.$1 == profile.name ? C.terracotta : C.card,
                            borderRadius: BorderRadius.circular(20),
                            border: m.$1 == profile.name ? null : Border.all(color: C.beige),
                          ),
                          child: Text(ld(context, m.$2),
                              style: TextStyle(
                                  color: m.$1 == profile.name ? Colors.white : C.ink,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ),
            ]),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 12),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _text,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(hintText: l.familyChatInputHint),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _send,
                  style: IconButton.styleFrom(backgroundColor: C.terracotta, foregroundColor: Colors.white),
                  icon: const Icon(Icons.send_rounded),
                ),
              ]),
            ),
          ),
        ]),
      );
  }
}
