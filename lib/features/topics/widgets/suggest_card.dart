import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';

/// "عندك سالفة ببالك؟": write a topic and add it to the family's own.
class SuggestCard extends StatefulWidget {
  /// Called with the trimmed, non-empty text.
  final ValueChanged<String> onAdd;
  const SuggestCard({super.key, required this.onAdd});

  @override
  State<SuggestCard> createState() => _SuggestCardState();
}

class _SuggestCardState extends State<SuggestCard> {
  final _text = TextEditingController();
  final _focus = FocusNode();

  bool get _canAdd => _text.text.trim().isNotEmpty;

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_canAdd) return;
    final v = _text.text.trim();
    _text.clear();
    _focus.unfocus();
    setState(() {});
    widget.onAdd(v);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AC.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AC.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AC.brick,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.add_comment_outlined,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.topicsSuggestTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AC.ink,
                      ),
                    ),
                    Text(
                      l.topicsSuggestSub,
                      style: const TextStyle(fontSize: 12, color: AC.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: Semantics(
                    label: l.topicsSuggestFieldLabel,
                    textField: true,
                    child: TextField(
                      controller: _text,
                      focusNode: _focus,
                      maxLength: 90,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _submit(),
                      style: const TextStyle(fontSize: 15, color: AC.ink),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: l.topicsSuggestHint,
                        hintStyle: const TextStyle(
                          fontSize: 15,
                          color: AC.muted,
                        ),
                        filled: true,
                        fillColor: AC.background,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AC.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AC.brick,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: _canAdd ? AC.brick : const Color(0xFFC9A79F),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _canAdd ? _submit : null,
                  child: Container(
                    height: 48,
                    constraints: const BoxConstraints(minWidth: 56),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.center,
                    child: Text(
                      l.topicsAdd,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
