import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/app_localizations.dart';
import '../../screens/activities_colors.dart';
import 'widgets/photo_area.dart';
import 'widgets/with_picker.dart';

/// What the "لحظة جديدة" screen hands back when the user shares.
class NewMomentDraft {
  final String imagePath, caption;
  final List<String> withIds;
  const NewMomentDraft({
    required this.imagePath,
    required this.caption,
    required this.withIds,
  });
}

typedef PhotoPicker = Future<String?> Function(ImageSource source);

/// Tests set this to skip the real camera/gallery.
@visibleForTesting
PhotoPicker? debugPhotoPickerOverride;

Future<String?> _pickWithImagePicker(ImageSource source) async {
  final f = await ImagePicker().pickImage(
    source: source,
    maxWidth: 1800,
    imageQuality: 85,
  );
  return f?.path;
}

/// Opens "لحظة جديدة" full screen, sliding up from the bottom (over the tab
/// bar). Completes with the draft when shared, or null when closed.
Future<NewMomentDraft?> showNewMoment(
  BuildContext context, {
  PhotoPicker? pickPhoto,
}) => Navigator.of(context, rootNavigator: true).push<NewMomentDraft>(
  PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (_, _, _) => NewMomentScreen(pickPhoto: pickPhoto),
    transitionsBuilder: (ctx, anim, _, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: const Cubic(.2, .8, .2, 1),
        reverseCurve: Curves.easeIn,
      );
      if (MediaQuery.disableAnimationsOf(ctx)) {
        return FadeTransition(opacity: anim, child: child);
      }
      return SlideTransition(
        position: Tween(
          begin: const Offset(0, .08),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  ),
);

class NewMomentScreen extends StatefulWidget {
  final PhotoPicker? pickPhoto;
  const NewMomentScreen({super.key, this.pickPhoto});

  @override
  State<NewMomentScreen> createState() => _NewMomentScreenState();
}

class _NewMomentScreenState extends State<NewMomentScreen> {
  final _caption = TextEditingController();
  final _with = <String>{};
  String? _photo;

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final path =
          await (widget.pickPhoto ??
              debugPhotoPickerOverride ??
              _pickWithImagePicker)(source);
      if (path != null && mounted) setState(() => _photo = path);
    } on PlatformException catch (e) {
      final denied =
          e.code == 'camera_access_denied' || e.code == 'photo_access_denied';
      if (!denied) rethrow;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              e.code == 'camera_access_denied'
                  ? l.momentsCameraDenied
                  : l.momentsPhotosDenied,
            ),
            action: SnackBarAction(
              label: l.momentsSettings,
              onPressed: AppSettings.openAppSettings,
            ),
          ),
        );
    }
  }

  void _share() {
    final p = _photo;
    if (p == null) return;
    Navigator.of(context).pop(
      NewMomentDraft(
        imagePath: p,
        caption: _caption.text.trim(),
        withIds: _with.toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom > 0;
    final can = _photo != null;
    return Scaffold(
      backgroundColor: AC.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AC.border)),
              ),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: l.momentsClose,
                    excludeSemantics: true,
                    child: Material(
                      color: AC.card,
                      shape: const CircleBorder(
                        side: BorderSide(color: AC.border),
                      ),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AC.ink,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      l.momentsNewTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AC.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PhotoArea(
                      path: _photo,
                      onCamera: () => _pick(ImageSource.camera),
                      onGallery: () => _pick(ImageSource.gallery),
                      onClear: () => setState(() => _photo = null),
                    ),
                    const SizedBox(height: 18),
                    _Label(
                      l.momentsWhatHappened,
                      trailing: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _caption,
                        builder: (_, v, _) => Text(
                          '${v.text.length}/80',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AC.muted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 52,
                      child: TextField(
                        controller: _caption,
                        maxLength: 80,
                        scrollPadding: const EdgeInsets.only(bottom: 160),
                        style: const TextStyle(fontSize: 15, color: AC.ink),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: l.momentsCaptionHint,
                          hintStyle: const TextStyle(
                            fontSize: 15,
                            color: AC.muted,
                          ),
                          filled: true,
                          fillColor: AC.card,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AC.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AC.brick,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _Label(
                      l.momentsWithWho,
                      trailing: Text(
                        l.momentsOptional,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AC.muted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    WithPicker(
                      selected: _with,
                      onToggle: (id) => setState(
                        () => _with.contains(id)
                            ? _with.remove(id)
                            : _with.add(id),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, keyboard ? 12 : 30),
              decoration: const BoxDecoration(
                color: AC.background,
                border: Border(top: BorderSide(color: AC.border)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!can) ...[
                    Text(
                      l.momentsPickPhotoFirst,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: AC.muted),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Material(
                    color: can ? AC.brick : AC.bookFormDisabled,
                    borderRadius: BorderRadius.circular(16),
                    elevation: can ? 4 : 0,
                    shadowColor: AC.brick.withValues(alpha: .3),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: can ? _share : null,
                      child: SizedBox(
                        height: 56,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // send arrow auto-mirrors in RTL: points left
                            const Icon(
                              Icons.send_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              l.momentsShareWithFamily,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
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
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final Widget trailing;
  const _Label(this.text, {required this.trailing});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AC.ink,
        ),
      ),
      trailing,
    ],
  );
}
