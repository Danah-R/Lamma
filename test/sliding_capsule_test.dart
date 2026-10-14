import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/widgets/sliding_capsule.dart';

void main() {
  testWidgets('the highlight slides to the new option instead of jumping', (
    t,
  ) async {
    var picked = 0;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => Padding(
              padding: const EdgeInsets.all(20),
              child: SlidingCapsule(
                labels: const ['٨', '١٢', '١٦'],
                selected: picked,
                onChanged: (i) => setState(() => picked = i),
                track: Colors.grey,
                thumb: Colors.blue,
              ),
            ),
          ),
        ),
      ),
    );
    double thumbStart() => t
        .widget<AnimatedPositionedDirectional>(
          find.byType(AnimatedPositionedDirectional),
        )
        .start!;
    final first = thumbStart();
    await t.tap(find.text('١٦'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
    final mid = thumbStart();
    // the target is two options along; a jump would already be there, a slide is still on its way
    await t.pump(const Duration(milliseconds: 400));
    final end = thumbStart();
    expect(picked, 2);
    expect(end, greaterThan(first));
    expect(end, closeTo(first + 2 * (end - first) / 2, 0.01));
    expect(
      t
          .widget<AnimatedPositionedDirectional>(
            find.byType(AnimatedPositionedDirectional),
          )
          .duration,
      const Duration(milliseconds: 280),
    );
    expect(mid, inInclusiveRange(first, end));
  });
}
