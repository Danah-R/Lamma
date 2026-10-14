import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data.dart';
import 'l10n/app_localizations.dart';
import 'l10n/data_localizations.dart';
import 'theme.dart';
import 'widgets/notification_bell.dart';

Future<T?> go<T>(BuildContext c, Widget page) =>
    Navigator.of(c).push<T>(MaterialPageRoute(builder: (_) => page));

/// Opens a game full-screen above the tab bar (root navigator), so the
/// bottom navigation never shows during a game.
Future<T?> goGame<T>(BuildContext c, Widget page) => Navigator.of(
  c,
  rootNavigator: true,
).push<T>(MaterialPageRoute(builder: (_) => page));

/// A character picture framed for a round avatar: zoomed in on the face, with a little
/// empty backdrop above the head so nothing is cut off. Fill a square with it.
class FaceImage extends StatelessWidget {
  final String asset;
  const FaceImage(this.asset, {super.key});
  static const zoom = 1.55; // how far in
  static const headRoom =
      0.11; // empty space above the head, as a fraction of the circle

  @override
  Widget build(BuildContext context) {
    final framing = characterFraming[asset] ?? (0.05, const Color(0xFFD0A67E));
    final hairTop = framing.$1, backdrop = framing.$2;
    return LayoutBuilder(
      builder: (context, box) {
        final s = box.maxWidth.isFinite ? box.maxWidth : 100.0;
        // put the top of the hair `headRoom` below the top of the circle
        final top = headRoom * s - hairTop * zoom * s;
        return ColoredBox(
          color: backdrop,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: -(zoom - 1) * s / 2,
                top: top,
                width: s * zoom,
                height: s * zoom,
                child: Image.asset(asset, fit: BoxFit.cover),
              ),
              // soften the seam where the picture starts, when there is backdrop above it
              if (top > 0)
                Positioned(
                  left: 0,
                  right: 0,
                  top: top - 1,
                  height: s * .12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [backdrop, backdrop.withValues(alpha: 0)],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

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
        color: C.line,
        shape: BoxShape.circle,
        border: Border.all(color: C.cream, width: 2),
      ),
      child: ClipOval(
        child: asset == null
            ? Center(
                child: Text(
                  name.characters.first,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: size * .42,
                  ),
                ),
              )
            : FaceImage(asset),
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
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final n in names)
        Align(widthFactor: .72, child: Avatar(n, size: size)),
    ],
  );
}

class LCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  const LCard({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: color ?? C.card,
    borderRadius: BorderRadius.circular(24),
    child: InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
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
    child: Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: C.navy,
            ),
          ),
        ),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: const TextStyle(
                color: C.brick,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
      ],
    ),
  );
}

/// Small quiet section heading, with an optional link on the far side.
class SectionLabel extends StatelessWidget {
  final String text;
  final String? action;
  final VoidCallback? onTap;
  const SectionLabel(this.text, {this.action, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: .3,
            color: C.inkSoft,
          ),
        ),
        const Spacer(),
        if (action != null)
          Text(
            action!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: C.brick,
            ),
          ),
      ],
    ),
  );
}

class Pill extends StatelessWidget {
  final String text;
  final Color color;
  final Color? fg;
  const Pill(this.text, {super.key, this.color = C.line, this.fg});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: fg ?? C.ink,
      ),
    ),
  );
}

/// Selectable chip used for interests, event types, filters.
class Choice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;
  final Color
  idle; // resting fill; use ivory when the chip sits on a white card
  const Choice(
    this.label,
    this.selected,
    this.onTap, {
    super.key,
    this.color = C.brick,
    this.idle = C.card,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? color : idle,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : C.ink,
        ),
      ),
    ),
  );
}

class Bar extends StatelessWidget {
  final double value;
  final Color color;
  final Color track;
  const Bar(
    this.value, {
    super.key,
    this.color = C.brick,
    this.track = const Color(0xFFEDEDED),
  });
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: LinearProgressIndicator(
      value: value,
      minHeight: 10,
      color: color,
      backgroundColor: track,
    ),
  );
}

class IconBubble extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const IconBubble(this.icon, this.color, {super.key, this.size = 46});
  @override
  Widget build(BuildContext context) {
    // pale palette colors (sage, peach, yellow, lavender) work as a fill with a dark icon;
    // brand colors (brick, teal, navy) work as a tinted fill with a colored icon
    final pale = color.computeLuminance() > .35;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: pale ? .55 : .14),
        borderRadius: BorderRadius.circular(size * .36),
      ),
      child: Icon(icon, color: pale ? C.ink : color, size: size * .5),
    );
  }
}

class Btn extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color color;
  final bool outlined;
  final bool enabled;
  const Btn(
    this.text, {
    super.key,
    this.icon,
    this.onTap,
    this.color = C.brick,
    this.outlined = false,
    this.enabled = true,
  });
  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ],
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    );
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
                shape: shape,
              ),
              child: child,
            )
          : FilledButton(
              onPressed: enabled ? (onTap ?? () {}) : null,
              style: FilledButton.styleFrom(
                disabledBackgroundColor: C.sand,
                disabledForegroundColor: C.inkSoft,
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: pad,
                shape: shape,
              ),
              child: child,
            ),
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
      padding: EdgeInsetsDirectional.fromSTEB(
        20,
        4,
        20,
        bottom == null ? 120 : 28,
      ),
      children: children,
    ),
    bottomNavigationBar: bottom == null
        ? null
        : SafeArea(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 12),
              child: bottom,
            ),
          ),
  );
}

/// Header for the root tabs: title, subtitle, avatar and bell.
class TabHeader extends StatelessWidget {
  final String title, subtitle;
  const TabHeader(this.title, this.subtitle, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 8),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: C.navy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: C.inkSoft, fontSize: 15),
              ),
            ],
          ),
        ),
        const NotificationBell(),
      ],
    ),
  );
}

class Field extends StatelessWidget {
  final String label;
  final String? hint;
  final int lines;
  final IconData? icon;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboard;
  final List<TextInputFormatter>? formatters;
  const Field(
    this.label, {
    super.key,
    this.hint,
    this.lines = 1,
    this.icon,
    this.controller,
    this.onChanged,
    this.keyboard,
    this.formatters,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 6, start: 4),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboard,
          inputFormatters: formatters,
          maxLines: lines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: C.inkSoft),
            prefixIcon: icon == null ? null : Icon(icon, color: C.inkSoft),
          ),
        ),
      ],
    ),
  );
}

/// Stand-in for a photo until real ones exist: a soft gradient with a photo icon.
class PhotoBox extends StatelessWidget {
  final Color a, b;
  final double radius;
  final double iconSize;
  const PhotoBox(
    this.a,
    this.b, {
    super.key,
    this.radius = 20,
    this.iconSize = 36,
  });
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [a.withValues(alpha: .55), b],
      ),
    ),
    child: Center(
      child: Icon(
        Icons.photo_rounded,
        size: iconSize,
        color: Colors.white.withValues(alpha: .85),
      ),
    ),
  );
}

/// Like / comments / share row used on moments and talk posts.
class Reactions extends StatelessWidget {
  final int likes, comments;
  final bool liked;
  final VoidCallback onLike, onComments;
  const Reactions({
    super.key,
    required this.likes,
    required this.comments,
    required this.liked,
    required this.onLike,
    required this.onComments,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Widget item(IconData i, String t, Color c, VoidCallback f) =>
        GestureDetector(
          onTap: f,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Icon(i, size: 19, color: c),
              const SizedBox(width: 5),
              Text(
                t,
                style: TextStyle(
                  color: c,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
    return Row(
      children: [
        item(
          liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          '$likes',
          liked ? C.brick : C.inkSoft,
          onLike,
        ),
        const SizedBox(width: 20),
        item(
          Icons.chat_bubble_outline_rounded,
          '$comments',
          C.inkSoft,
          onComments,
        ),
        const SizedBox(width: 20),
        item(Icons.share_outlined, l.commonShareAction, C.inkSoft, () {}),
      ],
    );
  }
}

/// Bottom sheet with the family's comments on a post.
void showComments(BuildContext context) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: C.cream,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
  ),
  builder: (c) {
    final l = AppLocalizations.of(c);
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        20,
        18,
        20,
        MediaQuery.of(c).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.commonComments,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          for (final cm in comments)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Avatar(cm.$1, size: 36),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ld(c, cm.$1),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(ld(c, cm.$2)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          TextField(
            decoration: InputDecoration(hintText: l.commonWriteCommentHint),
          ),
        ],
      ),
    );
  },
);

/// Tells the person how many points they just earned (and if they were first).
Future<void> pointsToast(BuildContext context, Future<int> earned) async {
  final messenger = ScaffoldMessenger.of(context);
  final l = AppLocalizations.of(context);
  final points = await earned;
  if (points <= 0) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          points >= firstComePoints.first
              ? l.pointsFirst(points)
              : l.pointsEarned(points),
        ),
      ),
    );
}

/// Redraws a screen whenever shared family data was refreshed from the database.
mixin SharedRefresh<T extends StatefulWidget> on State<T> {
  void _sharedChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    sharedTick.addListener(_sharedChanged);
  }

  @override
  void dispose() {
    sharedTick.removeListener(_sharedChanged);
    super.dispose();
  }
}

/// The people behind a count ("3 listened", "4 coming"): a picture and a name each.
class PeopleList extends StatelessWidget {
  final List<String> names;
  final Color? color; // text color (white on dark cards)
  const PeopleList(this.names, {super.key, this.color});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final n in names)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Avatar(n, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ld(context, n),
                  style: TextStyle(fontWeight: FontWeight.w700, color: color),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

/// Tap [header] (the pictures and the count) to open the list of those people right underneath,
/// in the same page. Tap again to close it.
class PeopleExpand extends StatefulWidget {
  final List<String> names;
  final Widget header;
  final Color? color;
  const PeopleExpand({
    super.key,
    required this.names,
    required this.header,
    this.color,
  });
  @override
  State<PeopleExpand> createState() => _PeopleExpandState();
}

class _PeopleExpandState extends State<PeopleExpand> {
  bool _open = false;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.names.isEmpty
            ? null
            : () => setState(() => _open = !_open),
        child: Row(children: [Expanded(child: widget.header)]),
      ),
      AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: _open && widget.names.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 8),
                child: PeopleList(widget.names, color: widget.color),
              )
            : const SizedBox(width: double.infinity),
      ),
    ],
  );
}
