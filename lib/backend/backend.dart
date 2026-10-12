import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data.dart';
import 'supabase_config.dart';

enum BackendError { invalidCode, tooManyAttempts, alreadyInFamily, network, other }

class BackendException implements Exception {
  final BackendError kind;
  final String? detail;
  BackendException(this.kind, [this.detail]);
  @override
  String toString() => 'BackendException($kind${detail == null ? '' : ': $detail'})';
}

/// Talks to the Lamma Supabase project. There is no email or phone sign-in: each
/// install signs in anonymously, and the family is found through the user id.
///
/// Every method takes an optional [client] so tests can use separate "phones".
class Backend {
  /// True once Supabase is initialised. Tests never initialise it, so the app
  /// keeps working offline (with the sample family) there.
  static bool enabled = false;

  static SupabaseClient get _default => Supabase.instance.client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      // sign-in links and OAuth redirects are not used (no email, no social login)
      authOptions: const FlutterAuthClientOptions(detectSessionInUri: false),
    );
    enabled = true;
  }

  static Future<void> _signIn(SupabaseClient c) async {
    if (c.auth.currentSession == null) await c.auth.signInAnonymously();
  }

  /// A returning install: signs in (silently) and loads its family if it has one.
  static Future<bool> restore({SupabaseClient? client}) async {
    final c = client ?? _default;
    try {
      await _signIn(c);
      return await loadFamily(client: c);
    } catch (e) {
      debugPrint('Backend.restore failed: $e');
      return false;
    }
  }

  /// The json the database functions expect for a profile.
  static Map<String, dynamic> profileJson({
    required String name,
    required String role,
    String? roleLabel,
    required int age,
    required String job,
    required bool livesWithFamily,
    String? phone,
    required Iterable<String> interests,
    required Iterable<String> outingTypes,
    required String prefer,
    required int avatar,
  }) =>
      {
        'display_name': name,
        'role': role,
        'role_label': roleLabel,
        'age': age,
        'job': job,
        'lives_with_family': livesWithFamily,
        'phone': phone,
        'interests': interests.toList(),
        'outing_types': outingTypes.toList(),
        'prefer': prefer,
        'avatar': avatar,
      };

  /// Checks a join code without joining. Returns the family's name, or throws.
  static Future<String> checkJoinCode(String code, {SupabaseClient? client}) async {
    final c = client ?? _default;
    final r = await _rpc(c, 'check_join_code', {'p_code': code});
    _throwIfError(r);
    return r['family_name'] as String;
  }

  static Future<void> createFamily(String familyName, Map<String, dynamic> profileJson, {SupabaseClient? client}) async {
    final c = client ?? _default;
    await _rpc(c, 'create_family', {'p_family_name': familyName, 'p_profile': profileJson});
    await loadFamily(client: c);
  }

  static Future<void> joinFamily(String code, Map<String, dynamic> profileJson, {SupabaseClient? client}) async {
    final c = client ?? _default;
    final r = await _rpc(c, 'join_family', {'p_code': code, 'p_profile': profileJson});
    _throwIfError(r);
    await loadFamily(client: c);
  }

  /// Fills [profile] and [members] from the database. False if this user has no family yet.
  static Future<bool> loadFamily({SupabaseClient? client}) async {
    final c = client ?? _default;
    final uid = c.auth.currentUser?.id;
    if (uid == null) return false;
    final rows = List<Map<String, dynamic>>.from(await c.from('members').select().order('created_at'));
    if (rows.isEmpty) return false;
    final fam = await c.from('families').select().single();
    final me = rows.firstWhere((r) => r['user_id'] == uid);

    members
      ..clear()
      ..addAll(rows.map(memberFromRow));
    profile
      ..family = fam['name'] as String
      ..familyCode = fam['join_code'] as String
      ..name = me['display_name'] as String
      ..role = me['role'] as String
      ..age = (me['age'] as int?) ?? profile.age
      ..job = (me['job'] as String?) ?? profile.job
      ..livesWithFamily = (me['lives_with_family'] as bool?) ?? true
      ..interests = {...List<String>.from(me['interests'] as List)}
      ..outingTypes = {...List<String>.from(me['outing_types'] as List)}
      ..prefer = (me['prefer'] as String?) ?? profile.prefer
      ..avatar = me['avatar'] as int
      ..memberId = me['id'] as String
      ..parent = me['is_parent'] as bool;
    return true;
  }

  /// Saves the profile fields people are allowed to edit.
  static Future<void> updateMyProfile(Map<String, dynamic> fields, {SupabaseClient? client}) async {
    final c = client ?? _default;
    await c.from('members').update(fields).eq('user_id', c.auth.currentUser!.id);
  }

  // ---- mapping

  static const _roleLabels = {'mom': 'Mom', 'dad': 'Dad', 'daughter': 'Daughter', 'brother': 'Son', 'other': 'Other'};

  static Member memberFromRow(Map<String, dynamic> r) {
    final role = r['role'] as String;
    final avatar = ((r['avatar'] as int?) ?? 0).clamp(0, characters.length - 1);
    return Member(
      role,
      r['display_name'] as String,
      (r['role_label'] as String?) ?? _roleLabels[role] ?? role,
      (r['age'] as int?) ?? 0,
      characters[avatar].$2,
      (r['points'] as int?) ?? 0,
      id: r['id'] as String,
      parent: r['is_parent'] as bool,
    );
  }

  // ---- plumbing

  static Future<Map<String, dynamic>> _rpc(SupabaseClient c, String fn, Map<String, dynamic> args) async {
    try {
      await _signIn(c);
      final r = await c.rpc(fn, params: args);
      return Map<String, dynamic>.from(r as Map);
    } on PostgrestException catch (e) {
      if (e.message.contains('already_in_family')) throw BackendException(BackendError.alreadyInFamily);
      throw BackendException(BackendError.other, e.message);
    } on AuthException catch (e) {
      throw BackendException(BackendError.other, e.message);
    } catch (e) {
      throw BackendException(BackendError.network, '$e');
    }
  }

  static void _throwIfError(Map<String, dynamic> r) {
    switch (r['error']) {
      case 'invalid_code':
        throw BackendException(BackendError.invalidCode);
      case 'too_many_attempts':
        throw BackendException(BackendError.tooManyAttempts);
      case null:
        return;
      default:
        throw BackendException(BackendError.other, '${r['error']}');
    }
  }
}
