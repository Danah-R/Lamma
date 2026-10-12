// Talks to the real Supabase project, so it only runs when asked:
//   LIVE_BACKEND=1 flutter test test/backend_live_test.dart
// It creates a test family and leaves it behind (delete families named "Live test family").
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/backend/backend.dart';
import 'package:lamma/backend/supabase_config.dart';
import 'package:lamma/data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Map<String, dynamic> _p(String name, String role, {String? label, String? phone}) => Backend.profileJson(
      name: name,
      role: role,
      roleLabel: label,
      age: 30,
      job: 'Working',
      livesWithFamily: true,
      phone: phone,
      interests: ['Coffee', 'Games'],
      outingTypes: ['Nature'],
      prefer: 'Games',
      avatar: 3,
    );

void main() {
  final live = Platform.environment['LIVE_BACKEND'] == '1';

  test('create a family on one phone, join it from another', () async {
    HttpOverrides.global = null; // allow real network in the test binding
    final a = SupabaseClient(supabaseUrl, supabaseAnonKey);
    final b = SupabaseClient(supabaseUrl, supabaseAnonKey);

    // phone A: a mom starts the family
    await Backend.createFamily('Live test family', _p('Amina', 'mom', phone: '0500000000'), client: a);
    expect(profile.isParent, isTrue);
    expect(profile.familyCode, startsWith('LAMMA-'));
    expect(members.map((m) => m.name), ['Amina']);
    final code = profile.familyCode;

    // phone B: checks a wrong code, then the right one (typed loosely) and joins
    await expectLater(Backend.checkJoinCode('LAMMA-NOPE99', client: b),
        throwsA(isA<BackendException>().having((e) => e.kind, 'kind', BackendError.invalidCode)));
    expect(await Backend.checkJoinCode(code.toLowerCase().replaceAll('-', ' '), client: b), 'Live test family');
    await Backend.joinFamily(code, _p('Reem', 'other', label: 'Grandma'), client: b);

    // B sees the whole family, and is not a parent
    expect(members.map((m) => m.name).toSet(), {'Amina', 'Reem'});
    expect(profile.name, 'Reem');
    expect(profile.isParent, isFalse);
    expect(members.firstWhere((m) => m.name == 'Reem').role, 'Grandma');

    // B edits their own avatar and it is saved
    await Backend.updateMyProfile({'avatar': 1}, client: b);
    await Backend.loadFamily(client: b);
    expect(profile.avatar, 1);

    // a returning install finds its family again
    expect(await Backend.restore(client: a), isTrue);
    expect(profile.name, 'Amina');
  }, skip: live ? false : 'set LIVE_BACKEND=1 to run against the real project');
}
