# Lamma database (Supabase)

Project: `lamma` (ref `xziczkgrcaurjdkfyray`). Schema lives in `migrations/` and was applied in order.

**No email or phone sign-in.** Each install signs in anonymously
(`supabase.auth.signInAnonymously()`), which gives it a private user id. Email sign-up is switched
off in the project's auth settings.

| What | How |
|---|---|
| Start a family | `supabase.rpc('create_family', params: {'p_family_name': ..., 'p_profile': {...}})` returns `join_code` |
| Join a family | `supabase.rpc('join_family', params: {'p_code': 'LAMMA-XXXXXX', 'p_profile': {...}})` returns the family, or `{"error": "invalid_code" \| "too_many_attempts"}` |
| Read the family | `from('families').select()` and `from('members').select()` (only your own family is visible) |
| Edit your profile | `from('members').update({...}).eq('user_id', uid)` (name, age, job, interests, avatar... not role, points or parent status) |
| Make someone a parent | `rpc('set_parent', {'p_member_id': ..., 'p_value': true})` (parents or the family's creator) |
| New join code | `rpc('regenerate_join_code')` (parents) |

`p_profile` keys: `display_name`, `role` (mom, dad, daughter, brother, other), `role_label`, `age`, `job`,
`lives_with_family`, `phone` (optional, only you can read it), `interests[]`, `outing_types[]`, `prefer`, `avatar`.

Join codes look like `LAMMA-K7P2QX` and are typed forgivingly (any case, with or without the prefix).
A user gets 8 wrong codes per hour. Tables cannot be written to directly, only through these functions.

## How the app uses it

- `lib/backend/backend.dart` is the only place that talks to Supabase. `lib/backend/supabase_config.dart`
  holds the project URL and the public anon key (safe to ship; never put a service_role key or access token there).
- App start (`main.dart`): signs in anonymously and, if this install already belongs to a family, goes straight in.
  If Supabase can't be reached, onboarding runs offline with the sample family.
- Onboarding: the invite code is checked as soon as it is entered (`check_join_code`); the family is created or
  joined at the last step (`create_family` / `join_family`).
- Account shows the family's join code (tap to copy). Changing your character saves to the database.
- Tests: `flutter test` never touches the network. Live checks are opt-in:
  `LIVE_BACKEND=1 flutter test test/backend_live_test.dart` (create + join with two separate clients) and
  `LIVE_BACKEND=1 LIVE_FLOW=create flutter test test/backend_ui_live_test.dart` (the real onboarding screens).
  They leave test families behind ("Live test family", "UI test family"); delete them in the dashboard.

## Shared family data (second migration set)

Everything below is private to the family and only written through functions (tables are read-only for the app):

| What | How |
|---|---|
| Finish something (first one gets the most: 20/15/10, then 5) | `rpc('claim_first', {'p_key': 'podcast'})` returns `{points, place}` or `{already: true}`; keys: `podcast`, `book`, `topic:<id>`, `event:<id>`, `moment:<day>`, `game:<name>:<day>` |
| Undo a claim (takes the points back) | `rpc('revoke_claim', {'p_key': ...})` |
| Parents add/remove points | `rpc('adjust_points', {'p_member_id', 'p_delta'})` |
| Events and who is coming | `rpc('add_event', ...)`, `rpc('set_going', {'p_event_id', 'p_going'})`; read `family_events`, `event_going` |
| Moments | `rpc('add_moment', {'p_caption'})`; read `family_moments` |
| Parents' rules (phone-free time, penalties, rewards) | `rpc('set_rules', {'p_data'})` (parents); read `family_rules`; `rpc('phone_free_done')` switches phone-free off after its window |
| Podcast questions | `rpc('add_question', {'p_scope': 'podcast', 'p_text'})`; read `family_questions` |

The app reloads all of it every 20 seconds and after changes (`Backend.refreshShared`). Live check:
`LIVE_BACKEND=1 flutter test test/backend_shared_live_test.dart` (leaves "Shared test family" and "Other family" behind).

## Monthly survey

`monthly_surveys` holds one answer set per person per month (`rpc('submit_survey', {'p_month': '2026-10', 'p_answers': {...}})`).
The answers are private: a person can read only their own (not parents, not the family).
