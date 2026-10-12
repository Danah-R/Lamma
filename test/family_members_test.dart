import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/data/family_members.dart';
import 'package:lamma/features/games/shared/family_players.dart';
import 'package:lamma/features/moments/moments_controller.dart';
import 'package:lamma/features/notifications/notification_events.dart';

void main() {
  test('one family list: names, genders, ids', () {
    final byName = {for (final m in familyMembers) m.name: m.gender};
    expect(byName['يوسف'], Gender.male);
    expect(byName['عبدالله'], Gender.male);
    expect(byName['سارة'], Gender.female);
    expect(byName['أمينة'], Gender.female);
    expect(byName['نورة'], Gender.female);
    expect(familyMembers.map((m) => m.id).toSet().length, familyMembers.length);
    expect(genderOfName('نورة'), Gender.female);
    expect(genderOfName('يوسف'), Gender.male);
  });

  test('games, moments and chat read the same list', () {
    expect(familyPlayers.map((p) => p.name), familyMembers.map((m) => m.name));
    expect(momentsMembers, same(familyMembers));
    expect(familyPlayers.map((p) => p.name), isNot(contains('آمنة')));
    expect(familyPlayers.map((p) => p.name), isNot(contains('نوف')));
  });

  test('verbs agree with gender', () {
    final at = DateTime(2025, 1, 1);
    String moment(String id) => NotificationEvents.momentShared(
      momentId: 1,
      authorId: id,
      caption: 'x',
      at: at,
    )!.text;
    expect(moment('sa'), 'سارة شاركت لحظة: x');
    expect(moment('am'), 'أمينة شاركت لحظة: x');
    expect(moment('no'), 'نورة شاركت لحظة: x');
    expect(moment('yo'), 'يوسف شارك لحظة: x');
    expect(moment('ab'), 'عبدالله شارك لحظة: x');
    String comment(String id) => NotificationEvents.momentComment(
      momentId: 1,
      commentIndex: 0,
      momentOwnerId: 'sa',
      authorId: id,
      text: 'y',
      at: at,
    )!.text;
    expect(comment('no'), 'نورة علّقت على لحظة سارة: y');
    expect(comment('yo'), 'يوسف علّق على لحظة سارة: y');
    String vote(String id) =>
        NotificationEvents.outingVote(actorId: id, at: at)!.text;
    expect(vote('no'), 'نورة صوّتت على طلعة الويكند');
    expect(vote('ab'), 'عبدالله صوّت على طلعة الويكند');
    String suggest(String id) => NotificationEvents.outingSuggested(
      actorId: id,
      place: 'وادي حنيفة',
      at: at,
    )!.text;
    expect(suggest('am'), 'أمينة اقترحت طلعة الويكند: وادي حنيفة');
    expect(suggest('yo'), 'يوسف اقترح طلعة الويكند: وادي حنيفة');
  });

  test('the old spellings are gone from the code', () {
    final old = RegExp(r'(?<![؀-ۿ])(آمنة|نوف)(?![؀-ۿ])');
    final hits = <String>[];
    for (final dir in ['lib', 'test']) {
      for (final f in Directory(dir).listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        if (f.path.endsWith('family_members_test.dart')) continue;
        if (old.hasMatch(f.readAsStringSync())) hits.add(f.path);
      }
    }
    expect(hits, isEmpty);
  });
}
