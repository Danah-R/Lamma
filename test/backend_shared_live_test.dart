// Talks to the real Supabase project, so it only runs when asked:
//   LIVE_BACKEND=1 flutter test test/backend_shared_live_test.dart
// It creates a test family and leaves it behind (delete families named "Shared test family").
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/backend/backend.dart';
import 'package:lamma/backend/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Map<String, dynamic> _p(String name, String role) => Backend.profileJson(
  name: name,
  role: role,
  age: 30,
  job: 'Working',
  livesWithFamily: true,
  interests: ['Coffee'],
  outingTypes: ['Nature'],
  prefer: 'Games',
  avatar: 2,
);

void main() {
  final live = Platform.environment['LIVE_BACKEND'] == '1';

  test(
    'points, first-come claims, events, moments, rules and questions are shared by the family',
    () async {
      HttpOverrides.global = null;
      final mom = SupabaseClient(supabaseUrl, supabaseAnonKey);
      final kid = SupabaseClient(supabaseUrl, supabaseAnonKey);
      final kid2 = SupabaseClient(supabaseUrl, supabaseAnonKey);
      final outsider = SupabaseClient(supabaseUrl, supabaseAnonKey);

      await Backend.createFamily(
        'Shared test family',
        _p('Amina', 'mom'),
        client: mom,
      );
      final code =
          (await mom.from('families').select().single())['join_code'] as String;
      await Backend.joinFamily(code, _p('Reem', 'daughter'), client: kid);
      await Backend.joinFamily(code, _p('Sara', 'daughter'), client: kid2);
      await Backend.createFamily(
        'Other family',
        _p('Zed', 'dad'),
        client: outsider,
      );

      Future<Map> claim(SupabaseClient c, String key) async =>
          Map.from(await c.rpc('claim_first', params: {'p_key': key}) as Map);
      Future<int> points(SupabaseClient c, String name) async {
        final rows = List<Map<String, dynamic>>.from(
          await c.from('members').select(),
        );
        return rows.firstWhere((r) => r['display_name'] == name)['points']
            as int;
      }

      // first one to finish gets the most, whoever is first on ANY phone
      var r = await claim(kid, 'podcast');
      expect([r['place'], r['points']], [1, 20]);
      r = await claim(kid2, 'podcast');
      expect([r['place'], r['points']], [2, 15]);
      r = await claim(mom, 'podcast');
      expect([r['place'], r['points']], [3, 10]);
      expect(
        (await claim(kid, 'podcast'))['already'],
        true,
        reason: 'counted once',
      );
      expect(
        await points(mom, 'Reem'),
        20,
        reason: 'the whole family sees the same points',
      );
      expect(await points(kid2, 'Amina'), 10);

      // another family has its own race
      r = await claim(outsider, 'podcast');
      expect([r['place'], r['points']], [1, 20]);
      expect(
        List.from(await outsider.from('family_claims').select()).length,
        1,
        reason: 'cannot see other families',
      );

      // undo takes the points back and frees the place
      await kid.rpc('revoke_claim', params: {'p_key': 'podcast'});
      expect(await points(mom, 'Reem'), 0);
      expect(
        List.from(await mom.from('family_claims').select().eq('key', 'podcast'))
            .length,
        2,
      );

      // nobody can write points or claims directly
      await expectLater(
        kid.from('members').update({'points': 999}).eq('display_name', 'Reem'),
        throwsA(anything),
      );
      await expectLater(
        kid.from('family_claims').insert({'key': 'x'}),
        throwsA(anything),
      );

      // only parents adjust points
      final reemId = (await kid
          .from('members')
          .select()
          .eq('display_name', 'Reem')
          .single())['id'];
      await expectLater(
        kid.rpc(
          'adjust_points',
          params: {'p_member_id': reemId, 'p_delta': 50},
        ),
        throwsA(anything),
      );
      await mom.rpc(
        'adjust_points',
        params: {'p_member_id': reemId, 'p_delta': 12},
      );
      expect(await points(kid2, 'Reem'), 12);

      // events everybody in the family sees, with who is coming
      final evId = await kid.rpc(
        'add_event',
        params: {
          'p_title': 'Picnic',
          'p_date': '2030-01-05',
          'p_time': '4:00 PM',
          'p_type': 'Outing',
        },
      );
      await kid2.rpc(
        'set_going',
        params: {'p_event_id': evId, 'p_going': true},
      );
      final evs = List<Map<String, dynamic>>.from(
        await mom.from('family_events').select(),
      );
      expect(evs.single['title'], 'Picnic');
      expect(List.from(await mom.from('event_going').select()).length, 2);
      expect(List.from(await outsider.from('family_events').select()), isEmpty);
      await expectLater(
        outsider.rpc(
          'set_going',
          params: {'p_event_id': evId, 'p_going': true},
        ),
        throwsA(anything),
      );

      // moments
      await kid.rpc('add_moment', params: {'p_caption': 'Baked a cake'});
      expect(
        List.from(await mom.from('family_moments').select()).single['caption'],
        'Baked a cake',
      );

      // parents' rules: parents write, everyone reads
      await mom.rpc(
        'set_rules',
        params: {
          'p_data': {'phoneFree': true, 'penalty': 7},
        },
      );
      expect(
        (await kid2.from('family_rules').select().single())['data']['penalty'],
        7,
      );
      await expectLater(
        kid.rpc(
          'set_rules',
          params: {
            'p_data': {'penalty': 1},
          },
        ),
        throwsA(anything),
      );
      await kid.rpc('phone_free_done');
      expect(
        (await mom.from('family_rules').select().single())['data']['phoneFree'],
        false,
      );
      expect(
        (await mom.from('family_rules').select().single())['data']['penalty'],
        7,
      );

      // topics: anyone adds, everyone sees, anyone marks it talked about
      final topicId = await kid.rpc(
        'add_topic',
        params: {'p_text': 'Where to travel?'},
      );
      expect(
        List.from(await mom.from('family_topics').select()).single['text'],
        'Where to travel?',
      );
      await kid2.rpc('topic_discussed', params: {'p_id': topicId});
      expect(
        List.from(await mom.from('family_topics').select())
            .single['discussed_at'],
        isNotNull,
      );
      expect(List.from(await outsider.from('family_topics').select()), isEmpty);

      // questions
      await kid.rpc(
        'add_question',
        params: {'p_scope': 'podcast', 'p_text': 'Who talks most?'},
      );
      expect(
        List.from(await kid2.from('family_questions').select()).single['text'],
        'Who talks most?',
      );
    },
    skip: live ? false : 'set LIVE_BACKEND=1 to run against the real project',
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
