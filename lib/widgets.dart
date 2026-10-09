import 'package:flutter/material.dart';
import 'data.dart';
import 'l10n/app_localizations.dart';
import 'l10n/data_localizations.dart';
import 'theme.dart';

Future<T?> go<T>(BuildContext c, Widget page) =>
    Navigator.of(c).push<T>(MaterialPageRoute(builder: (_) => page));

class Avatar extends StatelessWidget {
  final String name;
  final double size;
  const Avatar(this.name, {super.key, this.size = 40});
  @override
  Widget build(BuildContext context) {
    final asset = avatarAsset(name);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: C.beige,
        shape: BoxShape.circle,
        border: Border.all(color: C.cream, width: 2),
      ),
      child: ClipOval(
        child: asset == null
            ? Center(
                child: Text(name.characters.first,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: size * .42)))
            : Image.asset(asset, fit: BoxFit.cover, alignment: Alignment.topCenter),
      ),
    );
  }
}

/// Overlapping row of avatars.
class AvatarStack extends StatelessWidget {
  final List<String> names;
  final double size;
  const AvatarStack(this.names, {super.key, this.size = 32});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        for (final n in names) Align(widthFactor: .72, child: Avatar(n, size: size)),
      ]);
}

class LCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  const LCard(
      {super.key,
      required this.child,
      this.color,
      this.padding = const EdgeInsets.all(16),
      this.onTap});
  @override
  Widget build(BuildContext context) => Material(
        color: color ?? C.card,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: color == null ? Border.all(color: C.beige, width: 1.5) : null,
            ),
            child: child,
          ),
        ),
      );
}

class SectionTitle extends StatelessWidget {
  final String text;
  final String? action;
  final VoidCallback? onAction;
  const SectionTitle(this.text, {super.key, this.action, this.onAction});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(4, 26, 4, 12),
        child: Row(children: [
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!,
                  style: const TextStyle(
                      color: C.terracotta, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
        ]),
      );
}

class Pill extends StatelessWidget {
  final String text;
  final Color color;
  final Color? fg;
  const Pill(this.text, {super.key, this.color = C.beige, this.fg});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg ?? C.ink)),
      );
}

/// Selectable chip used for interests, event types, filters.
class Choice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;
  const Choice(this.label, this.selected, this.onTap, {super.key, this.color = C.navy});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color : C.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: selected ? color : C.sand),
          ),
          child: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : C.ink)),
        ),
      );
}

class Bar extends StatelessWidget {
  final double value;
  final Color color;
  final Color track;
  const Bar(this.value, {super.key, this.color = C.terracotta, this.track = C.beige});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
            value: value, minHeight: 10, color: color, backgroundColor: track),
      );
}

class IconBubble extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const IconBubble(this.icon, this.color, {super.key, this.size = 46});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: color.withValues(alpha: .18), borderRadius: BorderRadius.circular(size * .36)),
        child: Icon(icon, color: color, size: size * .5),
      );
}

class Btn extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color color;
  final bool outlined;
  final bool enabled;
  const Btn(this.text,
      {super.key,
      this.icon,
      this.onTap,
      this.color = C.terracotta,
      this.outlined = false,
      this.enabled = true});
  @override
  Widget build(BuildContext context) {
    final child = Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
      Flexible(
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
    ]);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(18));
    const pad = EdgeInsets.symmetric(vertical: 16, horizontal: 22);
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton(
              onPressed: enabled ? (onTap ?? () {}) : null,
              style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color, width: 1.5),
                  padding: pad,
                  shape: shape),
              child: child)
          : FilledButton(
              onPressed: enabled ? (onTap ?? () {}) : null,
              style: FilledButton.styleFrom(
                  disabledBackgroundColor: C.sand,
                  disabledForegroundColor: C.inkSoft,
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: pad,
                  shape: shape),
              child: child),
    );
  }
}

/// A standard pushed page: back arrow, title, padded scrolling body.
class Page1 extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? bottom;
  const Page1(this.title, this.children, {super.key, this.bottom});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: ListView(
            padding: EdgeInsetsDirectional.fromSTEB(20, 4, 20, bottom == null ? 120 : 28),
            children: children),
        bottomNavigationBar: bottom == null
            ? null
            : SafeArea(
                child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 12), child: bottom)),
      );
}

/// Header for the root tabs: title, subtitle, avatar and bell.
class TabHeader extends StatelessWidget {
  final String title, subtitle;
  final VoidCallback? onBell;
  const TabHeader(this.title, this.subtitle, {super.key, this.onBell});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(4, 12, 4, 8),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: C.inkSoft, fontSize: 15)),
            ]),
          ),
          if (onBell != null) BellButton(onBell!),
        ]),
      );
}

class BellButton extends StatelessWidget {
  final VoidCallback onTap;
  const BellButton(this.onTap, {super.key});
  @override
  Widget build(BuildContext context) => Stack(children: [
        IconButton.filled(
          onPressed: onTap,
          style: IconButton.styleFrom(backgroundColor: C.beige, foregroundColor: C.ink),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        PositionedDirectional(
            top: 8,
            end: 10,
            child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(color: C.coral, shape: BoxShape.circle))),
      ]);
}

class Field extends StatelessWidget {
  final String label;
  final String? hint;
  final int lines;
  final IconData? icon;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboard;
  const Field(this.label,
      {super.key,
      this.hint,
      this.lines = 1,
      this.icon,
      this.controller,
      this.onChanged,
      this.keyboard});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (label.isNotEmpty)
            Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 6, start: 4),
                child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
          TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: keyboard,
            maxLines: lines,
            decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: C.inkSoft),
                prefixIcon: icon == null ? null : Icon(icon, color: C.inkSoft)),
          ),
        ]),
      );
}

/// Stand-in for a photo until real ones exist: a soft gradient with a photo icon.
class PhotoBox extends StatelessWidget {
  final Color a, b;
  final double radius;
  final double iconSize;
  const PhotoBox(this.a, this.b, {super.key, this.radius = 20, this.iconSize = 36});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [a.withValues(alpha: .55), b]),
        ),
        child: Center(
            child: Icon(Icons.photo_rounded,
                size: iconSize, color: Colors.white.withValues(alpha: .85))),
      );
}

/// Like / comments / share row used on moments and talk posts.
class Reactions extends StatelessWidget {
  final int likes, comments;
  final bool liked;
  final VoidCallback onLike, onComments;
  const Reactions(
      {super.key,
      required this.likes,
      required this.comments,
      required this.liked,
      required this.onLike,
      required this.onComments});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Widget item(IconData i, String t, Color c, VoidCallback f) => GestureDetector(
          onTap: f,
          behavior: HitTestBehavior.opaque,
          child: Row(children: [
            Icon(i, size: 19, color: c),
            const SizedBox(width: 5),
            Text(t, style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
        );
    return Row(children: [
      item(liked ? Icons.favorite_rounded : Icons.favorite_border_rounded, '$likes',
          liked ? C.terracotta : C.inkSoft, onLike),
      const SizedBox(width: 20),
      item(Icons.chat_bubble_outline_rounded, '$comments', C.inkSoft, onComments),
      const SizedBox(width: 20),
      item(Icons.share_outlined, l.commonShareAction, C.inkSoft, () {}),
    ]);
  }
}

/// Bottom sheet with the family's comments on a post.
void showComments(BuildContext context) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: C.cream,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (c) {
        final l = AppLocalizations.of(c);
        return Padding(
          padding: EdgeInsetsDirectional.fromSTEB(20, 18, 20, MediaQuery.of(c).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.commonComments, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 14),
            for (final cm in comments)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Avatar(cm.$1, size: 36),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(ld(c, cm.$1), style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text(ld(c, cm.$2)),
                      ]),
                    ),
                  ),
                ]),
              ),
            TextField(decoration: InputDecoration(hintText: l.commonWriteCommentHint)),
          ]),
        );
      },
    );
