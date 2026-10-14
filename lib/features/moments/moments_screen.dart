import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../screens/activities_colors.dart';
import 'moments_controller.dart';
import 'new_moment_screen.dart';
import 'widgets/moment_card.dart';
import 'widgets/moments_header.dart';

/// "لحظات يومنا": the family's photo moments. Opened by the camera button
/// in the bottom bar; unrelated to the chat.
class MomentsScreen extends StatefulWidget {
  const MomentsScreen({super.key});

  // space the floating bottom bar occupies
  static const bottomInset = 130.0;

  @override
  State<MomentsScreen> createState() => MomentsScreenState();
}

class MomentsScreenState extends State<MomentsScreen> {
  final _scroll = ScrollController();
  final _cardKeys = <int, GlobalKey>{};

  /// Scrolls the feed to the card of moment [id] (from a notification).
  void scrollToMoment(int id) {
    final ctx = _cardKeys[id]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: .05,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Opens "لحظة جديدة"; on share, adds the moment to the top of the feed.
  Future<void> openNewMoment({PhotoPicker? pickPhoto}) async {
    final messenger = ScaffoldMessenger.of(context);
    final controller = context.read<MomentsController>();
    final published = AppLocalizations.of(context).momentsPublished;
    final fallback = AppLocalizations.of(context).momentsDefaultCaption;
    final draft = await showNewMoment(context, pickPhoto: pickPhoto);
    if (draft == null || !mounted) return;
    controller.addMoment(
      caption: draft.caption.isEmpty ? fallback : draft.caption,
      imagePath: draft.imagePath,
      withIds: draft.withIds,
    );
    HapticFeedback.mediumImpact();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(published)));
    if (_scroll.hasClients) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _scroll.jumpTo(0);
      } else {
        _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.watch<MomentsController>();
    return Scaffold(
      backgroundColor: AC.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            MomentsHeader(
              title: l.momentsTitle,
              subtitle: l.momentsSharedCount(c.sharedTodayCount),
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context)
                    .copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  controller: _scroll,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    14,
                    16,
                    14,
                    MomentsScreen.bottomInset,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final m in c.moments) ...[
                        MomentCard(
                          key: _cardKeys.putIfAbsent(m.id, GlobalKey.new),
                          moment: m,
                          myReaction: c.myReaction(m),
                          onReact: (k) => c.react(m.id, k),
                          onComment: (t) => c.addComment(m.id, t),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            l.momentsEnd,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AC.muted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
