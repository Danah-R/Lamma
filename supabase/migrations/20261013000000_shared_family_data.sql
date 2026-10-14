-- Lamma: everything a family shares.
--
-- Points and "first one to finish gets the most" claims, events and who is coming, moments, the parents'
-- rules, and the podcast club's questions. All of it is scoped to the signed-in user's family with row
-- level security. Like the rest of the schema, nothing is written to directly: the app calls the
-- functions below, which check who is asking.

-- ---------------------------------------------------------------- tables

-- One row per person per thing they finished ("podcast", "event:<id>", "moment:<day>", "game:seen:<day>", ...).
-- `place` is their position in the race for that key (1 = first) and `points` what it earned.
create table public.family_claims (
  id          uuid primary key default gen_random_uuid(),
  family_id   uuid not null references public.families (id) on delete cascade,
  member_id   uuid not null references public.members (id) on delete cascade,
  key         text not null check (char_length(key) between 1 and 120),
  place       int  not null check (place >= 1),
  points      int  not null check (points >= 0),
  created_at  timestamptz not null default now(),
  unique (family_id, key, member_id)
);
create index family_claims_key_idx on public.family_claims (family_id, key, place);

create table public.family_events (
  id          uuid primary key default gen_random_uuid(),
  family_id   uuid not null references public.families (id) on delete cascade,
  title       text not null check (char_length(btrim(title)) between 1 and 80),
  event_date  date not null,
  time_text   text not null default '',
  type        text not null default 'Gathering',
  created_by  uuid references public.members (id) on delete set null,
  created_at  timestamptz not null default now()
);
create index family_events_family_idx on public.family_events (family_id, event_date);

create table public.event_going (
  event_id   uuid not null references public.family_events (id) on delete cascade,
  member_id  uuid not null references public.members (id) on delete cascade,
  primary key (event_id, member_id)
);

create table public.family_moments (
  id          uuid primary key default gen_random_uuid(),
  family_id   uuid not null references public.families (id) on delete cascade,
  member_id   uuid not null references public.members (id) on delete cascade,
  caption     text not null check (char_length(btrim(caption)) between 1 and 300),
  created_at  timestamptz not null default now()
);
create index family_moments_family_idx on public.family_moments (family_id, created_at desc);

-- The parents' settings (phone-free time, penalties, rewards, active punishments) as one json document.
create table public.family_rules (
  family_id   uuid primary key references public.families (id) on delete cascade,
  data        jsonb not null default '{}'::jsonb,
  updated_at  timestamptz not null default now()
);

create table public.family_questions (
  id          uuid primary key default gen_random_uuid(),
  family_id   uuid not null references public.families (id) on delete cascade,
  member_id   uuid references public.members (id) on delete set null,
  scope       text not null check (scope in ('podcast', 'book')),
  text        text not null check (char_length(btrim(text)) between 1 and 200),
  created_at  timestamptz not null default now()
);
create index family_questions_family_idx on public.family_questions (family_id, scope, created_at);

-- ---------------------------------------------------------------- helpers

create function public.my_member()
returns public.members
language sql stable security definer set search_path = public
as $$ select * from public.members where user_id = auth.uid() $$;

-- ---------------------------------------------------------------- points

-- Records that the caller finished [p_key]. The first person in the family gets 20 points, the second 15,
-- the third 10 and everyone after 5. The race is decided here, under a lock, so two phones tapping at the
-- same moment get different places. Returns {points, place}, or {already: true} if it was counted before.
create function public.claim_first(p_key text)
returns jsonb
language plpgsql security definer set search_path = public
as $$
declare
  me public.members := public.my_member();
  existing public.family_claims;
  n int;
  pts int;
begin
  if me.id is null then raise exception 'not_in_family' using errcode = '42501'; end if;
  if p_key is null or char_length(p_key) not between 1 and 120 then
    raise exception 'bad_key' using errcode = '22023';
  end if;

  perform pg_advisory_xact_lock(hashtextextended(me.family_id::text || ':' || p_key, 0));

  select * into existing from public.family_claims
   where family_id = me.family_id and key = p_key and member_id = me.id;
  if found then
    return jsonb_build_object('already', true, 'points', existing.points, 'place', existing.place);
  end if;

  select count(*) into n from public.family_claims where family_id = me.family_id and key = p_key;
  pts := case n when 0 then 20 when 1 then 15 when 2 then 10 else 5 end;

  insert into public.family_claims (family_id, member_id, key, place, points)
  values (me.family_id, me.id, p_key, n + 1, pts);
  update public.members set points = points + pts where id = me.id;

  return jsonb_build_object('points', pts, 'place', n + 1);
end $$;

-- Takes the caller's claim back (an accidental tap) together with the points it gave.
create function public.revoke_claim(p_key text)
returns jsonb
language plpgsql security definer set search_path = public
as $$
declare
  me public.members := public.my_member();
  removed public.family_claims;
begin
  if me.id is null then raise exception 'not_in_family' using errcode = '42501'; end if;
  perform pg_advisory_xact_lock(hashtextextended(me.family_id::text || ':' || p_key, 0));
  delete from public.family_claims
   where family_id = me.family_id and key = p_key and member_id = me.id
   returning * into removed;
  if removed.id is null then return jsonb_build_object('points', 0); end if;
  update public.members set points = greatest(points - removed.points, 0) where id = me.id;
  return jsonb_build_object('points', removed.points);
end $$;

-- Parents add or remove points (a penalty for leaving the app, a correction).
create function public.adjust_points(p_member_id uuid, p_delta int)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  me public.members := public.my_member();
  target public.members;
begin
  select * into target from public.members where id = p_member_id;
  if me.id is null or target.id is null or me.family_id <> target.family_id or not me.is_parent then
    raise exception 'not_allowed' using errcode = '42501';
  end if;
  if p_delta not between -1000 and 1000 then raise exception 'bad_amount' using errcode = '22023'; end if;
  update public.members set points = greatest(points + p_delta, 0) where id = p_member_id;
end $$;

-- ---------------------------------------------------------------- events

create function public.add_event(p_title text, p_date date, p_time text, p_type text)
returns uuid
language plpgsql security definer set search_path = public
as $$
declare
  me public.members := public.my_member();
  new_id uuid;
begin
  if me.id is null then raise exception 'not_in_family' using errcode = '42501'; end if;
  insert into public.family_events (family_id, title, event_date, time_text, type, created_by)
  values (me.family_id, btrim(p_title), p_date, coalesce(p_time, ''), coalesce(nullif(p_type, ''), 'Gathering'), me.id)
  returning id into new_id;
  insert into public.event_going (event_id, member_id) values (new_id, me.id);
  return new_id;
end $$;

create function public.set_going(p_event_id uuid, p_going boolean)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  me public.members := public.my_member();
begin
  if me.id is null
     or not exists (select 1 from public.family_events where id = p_event_id and family_id = me.family_id) then
    raise exception 'not_allowed' using errcode = '42501';
  end if;
  if p_going then
    insert into public.event_going (event_id, member_id) values (p_event_id, me.id) on conflict do nothing;
  else
    delete from public.event_going where event_id = p_event_id and member_id = me.id;
  end if;
end $$;

-- ---------------------------------------------------------------- moments, rules, questions

create function public.add_moment(p_caption text)
returns uuid
language plpgsql security definer set search_path = public
as $$
declare
  me public.members := public.my_member();
  new_id uuid;
begin
  if me.id is null then raise exception 'not_in_family' using errcode = '42501'; end if;
  insert into public.family_moments (family_id, member_id, caption)
  values (me.family_id, me.id, btrim(p_caption)) returning id into new_id;
  return new_id;
end $$;

create function public.set_rules(p_data jsonb)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  me public.members := public.my_member();
begin
  if me.id is null or not me.is_parent then raise exception 'not_allowed' using errcode = '42501'; end if;
  insert into public.family_rules (family_id, data, updated_at)
  values (me.family_id, coalesce(p_data, '{}'::jsonb), now())
  on conflict (family_id) do update set data = excluded.data, updated_at = now();
end $$;

create function public.add_question(p_scope text, p_text text)
returns uuid
language plpgsql security definer set search_path = public
as $$
declare
  me public.members := public.my_member();
  new_id uuid;
begin
  if me.id is null then raise exception 'not_in_family' using errcode = '42501'; end if;
  insert into public.family_questions (family_id, member_id, scope, text)
  values (me.family_id, me.id, p_scope, btrim(p_text)) returning id into new_id;
  return new_id;
end $$;

-- ---------------------------------------------------------------- security

alter table public.family_claims    enable row level security;
alter table public.family_events    enable row level security;
alter table public.event_going      enable row level security;
alter table public.family_moments   enable row level security;
alter table public.family_rules     enable row level security;
alter table public.family_questions enable row level security;

create policy claims_select on public.family_claims
  for select to authenticated using (family_id = public.my_family_id());
create policy events_select on public.family_events
  for select to authenticated using (family_id = public.my_family_id());
create policy going_select on public.event_going
  for select to authenticated using (
    exists (select 1 from public.family_events e where e.id = event_id and e.family_id = public.my_family_id()));
create policy moments_select on public.family_moments
  for select to authenticated using (family_id = public.my_family_id());
create policy rules_select on public.family_rules
  for select to authenticated using (family_id = public.my_family_id());
create policy questions_select on public.family_questions
  for select to authenticated using (family_id = public.my_family_id());

revoke all on public.family_claims, public.family_events, public.event_going, public.family_moments,
              public.family_rules, public.family_questions from anon, authenticated;
grant select on public.family_claims, public.family_events, public.event_going, public.family_moments,
                public.family_rules, public.family_questions to authenticated;

revoke all on function public.my_member()                          from public, anon;
revoke all on function public.claim_first(text)                    from public, anon;
revoke all on function public.revoke_claim(text)                   from public, anon;
revoke all on function public.adjust_points(uuid, int)             from public, anon;
revoke all on function public.add_event(text, date, text, text)    from public, anon;
revoke all on function public.set_going(uuid, boolean)             from public, anon;
revoke all on function public.add_moment(text)                     from public, anon;
revoke all on function public.set_rules(jsonb)                     from public, anon;
revoke all on function public.add_question(text, text)             from public, anon;
grant execute on function public.my_member()                       to authenticated;
grant execute on function public.claim_first(text)                 to authenticated;
grant execute on function public.revoke_claim(text)                to authenticated;
grant execute on function public.adjust_points(uuid, int)          to authenticated;
grant execute on function public.add_event(text, date, text, text) to authenticated;
grant execute on function public.set_going(uuid, boolean)          to authenticated;
grant execute on function public.add_moment(text)                  to authenticated;
grant execute on function public.set_rules(jsonb)                  to authenticated;
grant execute on function public.add_question(text, text)          to authenticated;
