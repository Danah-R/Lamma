import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';
import '../notification_model.dart';
import '../notifications_controller.dart';
import 'notification_visuals.dart';

const _newRow = Color(0xFFFFF8F2);
const _rowDivider = Color(0xFFF6EFE4);

/// The content of the floating box: header, scrolling list, footer.
class NotificationPanel extends StatelessWidget {
  final NotificationsController controller;
  final ValueChanged<AppNotification> onOpen;
  final VoidCallback onSeeAll;
  const NotificationPanel({
    super.key,
    required this.controller,
    required this.onOpen,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final items = controller.items;
        final unread = controller.unreadCount;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AC.track)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.notifBellLabelNone,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AC.ink,
                          ),
                        ),
                        Text(
                          l.notifSummary(unread),
                          style: const TextStyle(fontSize: 12, color: AC.muted),
                        ),
                      ],
                    ),
                  ),
                  if (unread > 0)
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: controller.markAllRead,
                      child: SizedBox(
                        height: 44,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Center(
                            child: Text(
                              l.notifReadAll,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AC.brick,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Flexible(
              child: items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            size: 32,
                            color: AC.muted,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.notifPanelEmpty,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AC.muted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(scrollbars: false),
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: items.length,
                        itemBuilder: (context, i) => _Row(
                          n: items[i],
                          first: i == 0,
                          onTap: () => onOpen(items[i]),
                        ),
                      ),
                    ),
            ),
            Material(
              color: AC.background,
              child: InkWell(
                onTap: onSeeAll,
                child: Container(
                  height: 52,
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AC.track)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.open_in_full_rounded,
                        size: 16,
                        color: AC.navy,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l.notifSeeAll,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AC.navy,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  final AppNotification n;
  final bool first;
  final VoidCallback onTap;
  const _Row({required this.n, required this.first, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final unread = !n.isRead;
    return Material(
      color: unread ? _newRow : AC.card,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            border: first
                ? null
                : const Border(top: BorderSide(color: _rowDivider)),
          ),
          child: Row(
            children: [
              NotificationAvatar(n: n, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(notificationSpan(n, color: AC.ink, size: 14)),
                    const SizedBox(height: 2),
                    Text(
                      notificationTimeLabel(l, n.createdAt),
                      style: const TextStyle(fontSize: 12, color: AC.muted),
                    ),
                  ],
                ),
              ),
              if (n.thumbnail != null) ...[
                const SizedBox(width: 10),
                NotificationThumbView(thumb: n.thumbnail!),
              ],
              if (unread) ...[
                const SizedBox(width: 10),
                Semantics(
                  label: l.notifNewDot,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AC.brick,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
