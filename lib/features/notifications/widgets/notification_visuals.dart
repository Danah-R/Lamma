import 'dart:io';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';
import '../../moments/moments_controller.dart' show MomentScene;
import '../../moments/widgets/moment_scene.dart';
import '../../../widgets/photo_or_painted.dart';
import '../../../data.dart' as app;
import '../../../widgets.dart' show Avatar;
import '../notification_model.dart';

/// "قبل 5 دقايق" / "8:15 ص" / "أمس".
String notificationTimeLabel(
  AppLocalizations l,
  DateTime t, {
  DateTime? now,
  bool detailed = false,
}) {
  final n = now ?? DateTime.now();
  final diff = n.difference(t);
  if (diff.inSeconds.abs() < 60) return l.notifTimeNow;
  if (diff.inMinutes < 60 && !diff.isNegative) {
    return l.notifTimeAgo(diff.inMinutes);
  }
  final today = DateTime(n.year, n.month, n.day);
  final days = today.difference(DateTime(t.year, t.month, t.day)).inDays;
  final h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final mm = t.minute.toString().padLeft(2, '0');
  final clock = '$h12:$mm ${t.hour >= 12 ? l.chatPm : l.chatAm}';
  if (days == 1) {
    return detailed ? l.notifsYesterdayAt(clock) : l.notifYesterday;
  }
  if (days > 1) return '${t.day}/${t.month}';
  return clock;
}

/// The actor's circle, or the system icon in a teal-tint circle.
class NotificationAvatar extends StatelessWidget {
  final AppNotification n;
  final double size;
  final Color? ring;
  const NotificationAvatar({
    super.key,
    required this.n,
    this.size = 40,
    this.ring,
  });

  @override
  Widget build(BuildContext context) {
    final a = n.actorId == null ? null : notificationActors[n.actorId];
    if (a == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AC.tealTint,
          shape: BoxShape.circle,
          border: ring == null ? null : Border.all(color: ring!, width: 2),
        ),
        child: Icon(
          n.type == NotificationType.club
              ? Icons.menu_book_outlined
              : n.type == NotificationType.survey
              ? Icons.favorite_border_rounded
              : Icons.notifications_none_rounded,
          size: size * .5,
          color: AC.teal,
        ),
      );
    }
    // the person's real profile picture (the same one the rest of the app shows)
    final picture = Avatar(
      a.id == notificationMeId ? app.profile.name : a.name,
      size: size,
    );
    if (ring == null) return picture;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ring!, width: 2),
      ),
      child: ClipOval(child: picture),
    );
  }
}

/// Bold lead + normal rest, e.g. "**يوسف** علّق على لحظة سارة: …".
InlineSpan notificationSpan(
  AppNotification n, {
  required Color color,
  required double size,
  double height = 1.5,
  FontWeight leadWeight = FontWeight.w700,
}) {
  final lead = n.text.startsWith(n.lead) ? n.lead : '';
  final rest = n.text.substring(lead.length);
  return TextSpan(
    style: TextStyle(fontSize: size, height: height, color: color),
    children: [
      if (lead.isNotEmpty)
        TextSpan(
          text: lead,
          style: TextStyle(fontWeight: leadWeight),
        ),
      TextSpan(text: rest),
    ],
  );
}

/// The moment's picture, cropped to a small rounded square.
class NotificationThumbView extends StatelessWidget {
  final NotificationThumb thumb;
  final double size, radius;
  const NotificationThumbView({
    super.key,
    required this.thumb,
    this.size = 40,
    this.radius = 9,
  });

  @override
  Widget build(BuildContext context) {
    final scene =
        MomentScene.values.asNameMap()[thumb.scene] ?? MomentScene.park;
    final painted = CustomPaint(
      painter: MomentScenePainter(scene),
      size: Size.square(size),
    );
    final path = thumb.imagePath;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: path == null || path.startsWith('assets/')
            ? PhotoOrPainted(assetPath: path, fallback: painted)
            : Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => painted,
              ),
      ),
    );
  }
}
