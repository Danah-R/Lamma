import 'package:flutter/material.dart';
import '../data.dart';
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
  Widget build(BuildContext context) => Scaffold(
        body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 120), children: [
          TabHeader('Lamma', "Let's chat", onBell: () => go(context, const NotificationsPage())),
          const SectionTitle('Family talk'),
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
                        Text(t.who, style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text(t.time, style: const TextStyle(color: C.inkSoft, fontSize: 12)),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Text(t.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.4)),
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
          Btn('Open family chat', color: C.navy, onTap: () => go(context, const FamilyChatPage())),
          SectionTitle('Moments of our day',
              action: '+ Share moment', onAction: () async {
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
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 26, 12, 10),
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
                      Text(m.who,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                      Text(m.time, style: const TextStyle(color: Colors.white70, fontSize: 10)),
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
    final m = widget.m;
    return Page1('Moment', [
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
            Text(m.who, style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(m.time, style: const TextStyle(color: C.inkSoft, fontSize: 12)),
          ]),
        ),
      ]),
      const SizedBox(height: 12),
      Text(m.caption, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
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
  Widget build(BuildContext context) => Page1('Share a moment', [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(color: C.beige, borderRadius: BorderRadius.circular(24)),
            child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.camera_alt_rounded, size: 44, color: C.terracotta),
              SizedBox(height: 8),
              Text('Take or choose a photo',
                  style: TextStyle(color: C.inkSoft, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
        const SizedBox(height: 18),
        Field('', hint: "What's on your mind? (a word or two)", controller: _text),
        Wrap(spacing: 8, children: [
          for (final s in ['At the café', 'Walking', 'Cooking'])
            Choice(s, false, () => setState(() => _text.text = s), color: C.navy),
        ]),
      ],
          bottom: Btn('Share with family', icon: Icons.send_rounded, onTap: () {
            addPoints(profile.name, 10);
            moments.insert(
                0,
                Moment(profile.name, _text.text.trim().isEmpty ? 'A moment' : _text.text.trim(), 'Just now',
                    C.coral, C.coralTint, 0, 0));
            Navigator.pop(context);
          }));
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
    (n('girl'), 'What are we cooking tonight?'),
    (profile.name, "Let's go to the park!"),
    (n('mom'), 'Dinner will be ready soon'),
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
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Family chat')),
        body: Column(children: [
          Expanded(
            child: ListView(padding: const EdgeInsets.all(20), children: [
              for (final m in _msgs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Align(
                    alignment: m.$1 == profile.name ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment:
                          m.$1 == profile.name ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (m.$1 != profile.name)
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 2),
                            child: Text(m.$1,
                                style: const TextStyle(fontSize: 11, color: C.inkSoft, fontWeight: FontWeight.w700)),
                          ),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 270),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                          decoration: BoxDecoration(
                            color: m.$1 == profile.name ? C.teal : C.card,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(m.$2,
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
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _text,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(hintText: 'Write a message...'),
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
