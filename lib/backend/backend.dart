import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data.dart';
import '../theme.dart';
import 'supabase_config.dart';

enum BackendError {
  invalidCode,
  tooManyAttempts,
  alreadyInFamily,
  network,
  other,
}

class BackendException implements Exception {
  final BackendError kind;
  final String? detail;
  BackendException(this.kind, [this.detail]);
  @override
  String toString() =>
      'BackendException($kind${detail == null ? '' : ': $detail'})';
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
    _connectSharedData();
  }

  // ---- shared family data (points, claims, events, moments, rules, questions)

  static Timer? _poll;

  /// Hooks the app's data layer up to the database, and keeps it fresh while the app is open.
  static void _connectSharedData() {
    remoteClaim = (key) => _call('claim_first', {'p_key': key});
    remoteRevoke = (key) => _call('revoke_claim', {'p_key': key});
    remoteAdjust = (id, delta) async {
      await _call('adjust_points', {'p_member_id': id, 'p_delta': delta});
    };
    remoteAward = (id, points) async {
      await _call('award_points', {'p_member_id': id, 'p_points': points});
    };
    remotePhoneFreeDone = () async {
      await _call('phone_free_done', {});
    };
    Timer? debounce;
    remoteSaveRules = () {
      debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 600), () async {
        await _call('set_rules', {'p_data': rules.toJson()});
      });
    };
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 20), (_) => refreshShared());
  }

  /// Calls a database function; null if it failed (offline, not allowed...). Never throws.
  static Future<Map<String, dynamic>?> _call(
    String fn,
    Map<String, dynamic> args, {
    SupabaseClient? client,
  }) async {
    final c = client ?? _default;
    try {
      await _signIn(c);
      final r = await c.rpc(fn, params: args);
      if (r is Map) return Map<String, dynamic>.from(r);
      return <String, dynamic>{'result': r};
    } catch (e) {
      debugPrint('Backend.$fn failed: $e');
      return null;
    }
  }

  static bool _refreshing = false;

  /// Reloads everything the family shares and tells the screens to redraw.
  /// Safe to call often; a call while another is running is skipped.
  static Future<void> refreshShared({SupabaseClient? client}) async {
    if (!enabled && client == null) return;
    if (_refreshing || !sharedLive) return;
    _refreshing = true;
    try {
      final c = client ?? _default;
      if (!await loadFamily(client: c)) return;
      final byId = {for (final m in members) m.id: m.name};

      final claims = List<Map<String, dynamic>>.from(
        await c.from('family_claims').select().order('place'),
      );
      final byKey = <String, List<String>>{};
      for (final r in claims) {
        final name = byId[r['member_id']];
        if (name != null) (byKey[r['key'] as String] ??= []).add(name);
      }
      setFinishers(byKey);

      final evs = List<Map<String, dynamic>>.from(
        await c.from('family_events').select().order('event_date'),
      );
      final going = List<Map<String, dynamic>>.from(
        await c.from('event_going').select(),
      );
      events
        ..clear()
        ..addAll([
          for (final e in evs)
            Ev(
              e['title'] as String,
              DateTime.parse(e['event_date'] as String),
              e['time_text'] as String,
              e['type'] as String,
              _eventColor(e['type'] as String),
              [
                for (final g in going)
                  if (g['event_id'] == e['id'] && byId[g['member_id']] != null)
                    byId[g['member_id']]!,
              ],
              id: e['id'] as String,
            ),
        ]);

      final ms = List<Map<String, dynamic>>.from(
        await c
            .from('family_moments')
            .select()
            .order('created_at', ascending: false)
            .limit(40),
      );
      final keep = {
        for (final m in moments)
          if (m.id != null) m.id!: m,
      };
      moments
        ..clear()
        ..addAll([
          for (final m in ms)
            keep[m['id']] ??
                Moment(
                  byId[m['member_id']] ?? '',
                  m['caption'] as String,
                  momentTime(
                    DateTime.parse(m['created_at'] as String).toLocal(),
                  ),
                  C.peach,
                  C.peachTint,
                  0,
                  0,
                  id: m['id'] as String,
                ),
        ]);

      final rr = await c.from('family_rules').select().maybeSingle();
      if (rr != null)
        rules.applyJson(Map<String, dynamic>.from(rr['data'] as Map));

      final qs = List<Map<String, dynamic>>.from(
        await c
            .from('family_questions')
            .select()
            .eq('scope', 'podcast')
            .order('created_at'),
      );
      sharedQuestions = [for (final q in qs) q['text'] as String];

      final ts = List<Map<String, dynamic>>.from(
        await c.from('family_topics').select().order('created_at'),
      );
      sharedTopics = [
        for (final t in ts)
          FamilyTopic(
            t['id'] as String,
            t['text'] as String,
            t['member_id'] as String?,
            t['discussed_at'] != null,
          ),
      ];

      final os = List<Map<String, dynamic>>.from(
        await c.from('family_outings').select().order('created_at'),
      );
      suggestedOutings = [for (final o in os) o['name'] as String];

      sharedTick.value++;
    } catch (e) {
      debugPrint('Backend.refreshShared failed: $e');
    } finally {
      _refreshing = false;
    }
  }

  static Color _eventColor(String type) => [
    C.teal,
    C.yellow,
    C.peach,
    C.sage,
  ][eventTypes.indexOf(type).clamp(0, 99) % 4];

  /// "Today, 4:10 PM", "Yesterday", "3 days ago": the same style the sample feed used.
  static String momentTime(DateTime t) {
    final days = DateTime(
      today.year,
      today.month,
      today.day,
    ).difference(DateTime(t.year, t.month, t.day)).inDays;
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final clock =
        '$h:${t.minute.toString().padLeft(2, '0')} ${t.hour < 12 ? 'AM' : 'PM'}';
    if (days <= 0) return 'Today, $clock';
    if (days == 1) return 'Yesterday';
    return '$days days ago';
  }

  // ---- writes the screens use (each returns true when the database took it)

  static Future<bool> addEvent(
    String title,
    DateTime date,
    String time,
    String type,
  ) async {
    final r = await _call('add_event', {
      'p_title': title,
      'p_date':
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'p_time': time,
      'p_type': type,
    });
    if (r != null) await refreshShared();
    return r != null;
  }

  static Future<bool> setGoing(String eventId, bool going) async =>
      (await _call('set_going', {'p_event_id': eventId, 'p_going': going})) !=
      null;

  static Future<bool> addMoment(String caption) async {
    final r = await _call('add_moment', {'p_caption': caption});
    if (r != null) await refreshShared();
    return r != null;
  }

  /// Saves this month's survey answers (private to the person).
  static Future<bool> submitSurvey(
    String month,
    Map<String, dynamic> answers,
  ) async =>
      (await _call('submit_survey', {
        'p_month': month,
        'p_answers': answers,
      })) !=
      null;

  /// Whether this person already answered the survey for [month] (on any phone).
  static Future<bool> surveyAnswered(String month) async {
    try {
      final rows = await _default
          .from('monthly_surveys')
          .select('month')
          .eq('month', month);
      return rows.isNotEmpty;
    } catch (e) {
      debugPrint('Backend.surveyAnswered failed: $e');
      return false;
    }
  }

  static Future<bool> addOuting(String name) async {
    final r = await _call('add_outing', {'p_name': name});
    if (r != null) await refreshShared();
    return r != null;
  }

  static Future<bool> addTopic(String text) async {
    final r = await _call('add_topic', {'p_text': text});
    if (r != null) await refreshShared();
    return r != null;
  }

  static Future<bool> topicDiscussed(String id) async {
    final r = await _call('topic_discussed', {'p_id': id});
    if (r != null) await refreshShared();
    return r != null;
  }

  static Future<bool> addQuestion(String text) async {
    final r = await _call('add_question', {
      'p_scope': 'podcast',
      'p_text': text,
    });
    if (r != null) await refreshShared();
    return r != null;
  }

  static Future<void> _signIn(SupabaseClient c) async {
    if (c.auth.currentSession == null) await c.auth.signInAnonymously();
  }

  /// A returning install: signs in (silently) and loads its family if it has one.
  static Future<bool> restore({SupabaseClient? client}) async {
    final c = client ?? _default;
    try {
      await _signIn(c);
      final ok = await loadFamily(client: c);
      if (ok) refreshShared(client: c);
      return ok;
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
  }) => {
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
  static Future<String> checkJoinCode(
    String code, {
    SupabaseClient? client,
  }) async {
    final c = client ?? _default;
    final r = await _rpc(c, 'check_join_code', {'p_code': code});
    _throwIfError(r);
    return r['family_name'] as String;
  }

  static Future<void> createFamily(
    String familyName,
    Map<String, dynamic> profileJson, {
    SupabaseClient? client,
  }) async {
    final c = client ?? _default;
    await _rpc(c, 'create_family', {
      'p_family_name': familyName,
      'p_profile': profileJson,
    });
    await loadFamily(client: c);
    refreshShared(client: c);
  }

  static Future<void> joinFamily(
    String code,
    Map<String, dynamic> profileJson, {
    SupabaseClient? client,
  }) async {
    final c = client ?? _default;
    final r = await _rpc(c, 'join_family', {
      'p_code': code,
      'p_profile': profileJson,
    });
    _throwIfError(r);
    await loadFamily(client: c);
    refreshShared(client: c);
  }

  /// Fills [profile] and [members] from the database. False if this user has no family yet.
  static Future<bool> loadFamily({SupabaseClient? client}) async {
    final c = client ?? _default;
    final uid = c.auth.currentUser?.id;
    if (uid == null) return false;
    final rows = List<Map<String, dynamic>>.from(
      await c.from('members').select().order('created_at'),
    );
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
    sharedLive = true;
    return true;
  }

  /// Saves the profile fields people are allowed to edit.
  static Future<void> updateMyProfile(
    Map<String, dynamic> fields, {
    SupabaseClient? client,
  }) async {
    final c = client ?? _default;
    await c
        .from('members')
        .update(fields)
        .eq('user_id', c.auth.currentUser!.id);
  }

  /// The phone number (private to this person, optional).
  static Future<String?> loadMyPhone({SupabaseClient? client}) async {
    final c = client ?? _default;
    final r = await c.from('member_private').select('phone').maybeSingle();
    return r?['phone'] as String?;
  }

  static Future<void> saveMyPhone(
    String? phone, {
    SupabaseClient? client,
  }) async {
    final c = client ?? _default;
    final uid = c.auth.currentUser!.id;
    final v = (phone == null || phone.trim().isEmpty) ? null : phone.trim();
    if (v == null) {
      await c.from('member_private').delete().eq('user_id', uid);
    } else {
      await c.from('member_private').upsert({'user_id': uid, 'phone': v});
    }
  }

  // ---- mapping

  static const _roleLabels = {
    'mom': 'Mom',
    'dad': 'Dad',
    'daughter': 'Daughter',
    'brother': 'Son',
    'other': 'Other',
  };

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

  static Future<Map<String, dynamic>> _rpc(
    SupabaseClient c,
    String fn,
    Map<String, dynamic> args,
  ) async {
    try {
      await _signIn(c);
      final r = await c.rpc(fn, params: args);
      return Map<String, dynamic>.from(r as Map);
    } on PostgrestException catch (e) {
      if (e.message.contains('already_in_family'))
        throw BackendException(BackendError.alreadyInFamily);
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
