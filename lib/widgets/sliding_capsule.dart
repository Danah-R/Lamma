import 'package:flutter/material.dart';

/// A rounded capsule of options. The chosen one is highlighted by a rounded "thumb" that slides
/// to the new option (instead of the highlight jumping), and its label fades to the new color.
///
/// [selected] may be null (nothing chosen: the thumb fades out). [segmentWidth] gives every option a
/// fixed width (a small capsule inside a row); without it the capsule fills the width it is given.
class SlidingCapsule extends StatelessWidget {
  final List<String> labels;
  final int? selected;
  final ValueChanged<int> onChanged;
  final Color track, thumb, selectedText, idleText;

  /// A color per option for the thumb (for example one per team); falls back to [thumb].
  final List<Color>? thumbColors;
  final double height, fontSize;
  final double? segmentWidth;
  const SlidingCapsule({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
    required this.track,
    required this.thumb,
    this.selectedText = Colors.white,
    this.idleText = const Color(0xFF6B5D55),
    this.thumbColors,
    this.height = 48,
    this.fontSize = 15,
    this.segmentWidth,
  });

  static const _inset = 4.0;
  static const _slide = Duration(milliseconds: 280);

  @override
  Widget build(BuildContext context) {
    final n = labels.length;
    return SizedBox(
      height: height,
      width: segmentWidth == null ? double.infinity : segmentWidth! * n,
      child: LayoutBuilder(
        builder: (context, box) {
          final segW = box.maxWidth / n;
          final index = selected ?? 0;
          final color = thumbColors != null && selected != null
              ? thumbColors![selected!]
              : thumb;
          return DecoratedBox(
            decoration: BoxDecoration(
              color: track,
              borderRadius: BorderRadius.circular(height),
            ),
            child: Stack(
              children: [
                // the highlight that slides to the chosen option
                AnimatedPositionedDirectional(
                  duration: _slide,
                  curve: Curves.easeOutCubic,
                  start: index * segW + _inset,
                  top: _inset,
                  bottom: _inset,
                  width: segW - 2 * _inset,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: selected == null ? 0 : 1,
                    child: AnimatedContainer(
                      duration: _slide,
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(height),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < n; i++)
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: i == selected,
                          label: labels[i],
                          excludeSemantics: true,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onChanged(i),
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: _slide,
                                curve: Curves.easeOut,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w700,
                                  color: i == selected
                                      ? selectedText
                                      : idleText,
                                ),
                                child: Text(
                                  labels[i],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
        },
      ),
    );
  }
}
