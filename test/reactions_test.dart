import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lamma/features/moments/moments_controller.dart';

void main() {
  test(
    'one reaction per person: pick, change, take back; the count follows',
    () {
      final c = MomentsController();
      final id = c.moments.first.id;
      final before = c.moments.first.likedBy.length;
      expect(c.myReaction(c.byId(id)!), isNull);

      c.react(id, 'laugh');
      expect(c.myReaction(c.byId(id)!), 'laugh');
      expect(c.byId(id)!.likedBy.length, before + 1);

      c.react(id, 'cry'); // changing it does not add a second one
      expect(c.myReaction(c.byId(id)!), 'cry');
      expect(c.byId(id)!.likedBy.length, before + 1);

      c.react(id, 'cry'); // tapping the same one again takes it back
      expect(c.myReaction(c.byId(id)!), isNull);
      expect(c.byId(id)!.likedBy.length, before);

      c.toggleLike(id); // the old heart still works
      expect(c.isLiked(c.byId(id)!), isTrue);
      expect(momentReactions, ['heart', 'laugh', 'thumbs', 'cry', 'love']);
    },
  );

  testWidgets(
    'tapping the reactions count pops up who reacted and with what; tapping away closes it',
    (t) async {
      SharedPreferences.setMockInitialValues({'moments_coach_seen': true});
      await t.binding.setSurfaceSize(const Size(400, 900));
      await t.pumpWidget(
        const LammaApp(
          skipSplash: true,
          skipOnboarding: true,
          demoNotifications: false,
        ),
      );
      await t.tap(find.byIcon(Icons.camera_alt_rounded));
      await t.pump(const Duration(milliseconds: 600));
      await t.tap(find.byIcon(Icons.add_reaction_outlined).first);
      await t.pump(const Duration(milliseconds: 400));
      // the sample moment's reactions show as a small pop-up with a heart next to each person
      expect(find.text('❤️'), findsWidgets);
      expect(find.byType(Material), findsWidgets);
      await t.tapAt(const Offset(5, 5)); // anywhere else
      await t.pump(const Duration(milliseconds: 400));
      expect(find.byType(DialogRoute), findsNothing);
    },
  );
}
