-- Lamma: families, members and join codes.
--
-- No email or phone sign-in. Each app install signs in anonymously (Supabase
-- "anonymous sign-ins"), which gives it a private user id. Everything below is
-- scoped to that id with row level security.
--
-- Creating or joining a family goes through two functions (create_family,
-- join_family). Tables cannot be inserted into directly, so the checks cannot be
-- skipped.

-- ---------------------------------------------------------------- tables

create table public.families (
  id          uuid primary key default gen_random_uuid(),
  name        text not null check (char_length(btrim(name)) between 1 and 60),
  join_code   text not null unique,
  created_by  uuid references auth.users (id) on delete set null,
  created_at  timestamptz not null default now()
);

create table public.members (
  id                 uuid primary key default gen_random_uuid(),
  user_id            uuid not null unique references auth.users (id) on delete cascade,
  family_id          uuid not null references public.families (id) on delete cascade,
  display_name       text not null check (char_length(btrim(display_name)) between 1 and 40),
  role               text not null check (role in ('mom', 'dad', 'daughter', 'brother', 'other')),
  role_label         text check (role_label is null or char_length(btrim(role_label)) between 1 and 40),
  age                int  check (age between 3 and 110),
  job                text,
  lives_with_family  boolean,
  interests          text[] not null default '{}',
  outing_types       text[] not null default '{}',
  prefer             text check (prefer in ('Games', 'Discussions')),
  avatar             int  not null default 0 check (avatar between 0 and 5),
  is_parent          boolean not null default false,
  points             int  not null default 0 check (points >= 0),
  created_at         timestamptz not null default now()
);
create index members_family_id_idx on public.members (family_id);

-- The phone number is optional contact info (not used to sign in) and is only
-- visible to its owner.
create table public.member_private (
  user_id  uuid primary key references auth.users (id) on delete cascade,
  phone    text check (phone is null or char_length(phone) between 7 and 20)
);

-- Failed join attempts, used to slow down guessing of join codes.
create table public.join_attempts (
  id          bigint generated always as identity primary key,
  user_id     uuid not null references auth.users (id) on delete cascade,
  created_at  timestamptz not null default now()
);
create index join_attempts_user_idx on public.join_attempts (user_id, created_at desc);

-- ---------------------------------------------------------------- helpers

-- The family the signed-in user belongs to (null if none). SECURITY DEFINER so
-- policies can use it without recursing into the members table.
create function public.my_family_id()
returns uuid
language sql stable security definer set search_path = public
as $$ select family_id from public.members where user_id = auth.uid() $$;

-- Readable join codes without look-alike characters (no 0/O, 1/I/L).
create function public.generate_join_code()
returns text
language plpgsql volatile set search_path = public
as $$
declare
  alphabet constant text := 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  candidate text;
  i int;
begin
  loop
    candidate := 'LAMMA-';
    for i in 1..6 loop
      candidate := candidate || substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1);
    end loop;
    exit when not exists (select 1 from public.families where join_code = candidate);
  end loop;
  return candidate;
end $$;

-- Validates the profile json sent by the app and inserts the member. Internal.
create function public.insert_member(p_family uuid, p_profile jsonb, p_is_parent boolean)
returns public.members
language plpgsql security definer set search_path = public
as $$
declare
  uid uuid := auth.uid();
  m public.members;
  phone_text text := nullif(btrim(coalesce(p_profile ->> 'phone', '')), '');
begin
  insert into public.members (
    user_id, family_id, display_name, role, role_label, age, job,
    lives_with_family, interests, outing_types, prefer, avatar, is_parent
  ) values (
    uid, p_family,
    btrim(p_profile ->> 'display_name'),
    p_profile ->> 'role',
    nullif(btrim(coalesce(p_profile ->> 'role_label', '')), ''),
    nullif(p_profile ->> 'age', '')::int,
    p_profile ->> 'job',
    nullif(p_profile ->> 'lives_with_family', '')::boolean,
    coalesce(array(select jsonb_array_elements_text(coalesce(p_profile -> 'interests', '[]'::jsonb))), '{}'),
    coalesce(array(select jsonb_array_elements_text(coalesce(p_profile -> 'outing_types', '[]'::jsonb))), '{}'),
    p_profile ->> 'prefer',
    coalesce(nullif(p_profile ->> 'avatar', '')::int, 0),
    p_is_parent
  ) returning * into m;

  if phone_text is not null then
    insert into public.member_private (user_id, phone) values (uid, phone_text)
    on conflict (user_id) do update set phone = excluded.phone;
  end if;
  return m;
end $$;

-- ---------------------------------------------------------------- the app's functions

-- Creates a family and puts the caller in it. Returns the family and its join code.
create function public.create_family(p_family_name text, p_profile jsonb)
returns jsonb
language plpgsql security definer set search_path = public
as $$
declare
  uid uuid := auth.uid();
  fam public.families;
  m public.members;
begin
  if uid is null then raise exception 'not_signed_in' using errcode = '28000'; end if;
  if exists (select 1 from public.members where user_id = uid) then
    raise exception 'already_in_family' using errcode = 'P0001';
  end if;

  insert into public.families (name, join_code, created_by)
  values (btrim(p_family_name), public.generate_join_code(), uid)
  returning * into fam;

  -- only a mom or dad who starts the family is a parent from the start;
  -- parents can later promote others with set_parent()
  m := public.insert_member(fam.id, p_profile, (p_profile ->> 'role') in ('mom', 'dad'));

  return jsonb_build_object('family_id', fam.id, 'family_name', fam.name,
                            'join_code', fam.join_code, 'member_id', m.id);
end $$;

-- Joins the family that owns the join code. A wrong code gives a generic error,
-- and a user is limited to 8 failed codes per hour.
create function public.join_family(p_code text, p_profile jsonb)
returns jsonb
language plpgsql security definer set search_path = public
as $$
declare
  uid uuid := auth.uid();
  code text := upper(regexp_replace(coalesce(p_code, ''), '\s', '', 'g'));
  fam public.families;
  m public.members;
begin
  if uid is null then raise exception 'not_signed_in' using errcode = '28000'; end if;
  if exists (select 1 from public.members where user_id = uid) then
    raise exception 'already_in_family' using errcode = 'P0001';
  end if;

  if (select count(*) from public.join_attempts
      where user_id = uid and created_at > now() - interval '1 hour') >= 8 then
    raise exception 'too_many_attempts' using errcode = 'P0001';
  end if;

  if code !~ '^LAMMA-' then code := 'LAMMA-' || code; end if;
  select * into fam from public.families where join_code = code;
  if not found then
    insert into public.join_attempts (user_id) values (uid);
    raise exception 'invalid_code' using errcode = 'P0001';
  end if;

  m := public.insert_member(fam.id, p_profile, false);

  return jsonb_build_object('family_id', fam.id, 'family_name', fam.name,
                            'join_code', fam.join_code, 'member_id', m.id);
end $$;

-- Parents (or whoever created the family) can make another member a parent.
create function public.set_parent(p_member_id uuid, p_value boolean)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  me public.members;
  target public.members;
begin
  select * into me from public.members where user_id = auth.uid();
  select * into target from public.members where id = p_member_id;
  if me.id is null or target.id is null or me.family_id <> target.family_id then
    raise exception 'not_allowed' using errcode = '42501';
  end if;
  if not (me.is_parent or exists (select 1 from public.families
                                  where id = me.family_id and created_by = auth.uid())) then
    raise exception 'not_allowed' using errcode = '42501';
  end if;
  update public.members set is_parent = p_value where id = p_member_id;
end $$;

-- A parent can issue a fresh join code (e.g. if the old one was shared too widely).
create function public.regenerate_join_code()
returns text
language plpgsql security definer set search_path = public
as $$
declare
  me public.members;
  new_code text := public.generate_join_code();
begin
  select * into me from public.members where user_id = auth.uid();
  if me.id is null or not me.is_parent then
    raise exception 'not_allowed' using errcode = '42501';
  end if;
  update public.families set join_code = new_code where id = me.family_id;
  return new_code;
end $$;

-- ---------------------------------------------------------------- security

alter table public.families       enable row level security;
alter table public.members        enable row level security;
alter table public.member_private enable row level security;
alter table public.join_attempts  enable row level security;

-- read your own family and the people in it
create policy families_select on public.families
  for select to authenticated using (id = public.my_family_id());
create policy members_select on public.members
  for select to authenticated using (family_id = public.my_family_id());
-- edit only your own row, and leave the family
create policy members_update_own on public.members
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy members_delete_own on public.members
  for delete to authenticated using (user_id = auth.uid());
-- your own phone number
create policy private_select_own on public.member_private
  for select to authenticated using (user_id = auth.uid());
create policy private_write_own on public.member_private
  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
-- join_attempts: no policies, so only the functions above can touch it

-- Tables: nothing is writable directly except the profile fields below.
revoke all on public.families, public.members, public.member_private, public.join_attempts
  from anon, authenticated;
grant select on public.families to authenticated;
grant select, delete on public.members to authenticated;
-- not family_id, role, is_parent or points: those cannot be self-edited
grant update (display_name, role_label, age, job, lives_with_family,
              interests, outing_types, prefer, avatar) on public.members to authenticated;
grant select, insert, update, delete on public.member_private to authenticated;

-- Functions: signed-in (including anonymous) users only.
revoke all on function public.my_family_id()              from public, anon;
revoke all on function public.generate_join_code()        from public, anon, authenticated;
revoke all on function public.insert_member(uuid, jsonb, boolean) from public, anon, authenticated;
revoke all on function public.create_family(text, jsonb)  from public, anon;
revoke all on function public.join_family(text, jsonb)    from public, anon;
revoke all on function public.set_parent(uuid, boolean)   from public, anon;
revoke all on function public.regenerate_join_code()      from public, anon;
grant execute on function public.my_family_id()              to authenticated;
grant execute on function public.create_family(text, jsonb)  to authenticated;
grant execute on function public.join_family(text, jsonb)    to authenticated;
grant execute on function public.set_parent(uuid, boolean)   to authenticated;
grant execute on function public.regenerate_join_code()      to authenticated;
