-- Lamma: the monthly "how was your month with the family?" survey.
--
-- One answer set per person per month. The answers are private: only the person who gave them can read
-- them (not the parents, not the rest of the family). The app writes through submit_survey() only.

create table public.monthly_surveys (
  id          uuid primary key default gen_random_uuid(),
  family_id   uuid not null references public.families (id) on delete cascade,
  member_id   uuid not null references public.members (id) on delete cascade,
  month       text not null check (month ~ '^[0-9]{4}-(0[1-9]|1[0-2])$'),
  answers     jsonb not null default '{}'::jsonb,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (member_id, month)
);

create function public.submit_survey(p_month text, p_answers jsonb)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  me public.members := public.my_member();
begin
  if me.id is null then raise exception 'not_in_family' using errcode = '42501'; end if;
  if p_month !~ '^[0-9]{4}-(0[1-9]|1[0-2])$' then raise exception 'bad_month' using errcode = '22023'; end if;
  if pg_column_size(p_answers) > 20000 then raise exception 'too_big' using errcode = '22023'; end if;
  insert into public.monthly_surveys (family_id, member_id, month, answers)
  values (me.family_id, me.id, p_month, coalesce(p_answers, '{}'::jsonb))
  on conflict (member_id, month) do update set answers = excluded.answers, updated_at = now();
end $$;

alter table public.monthly_surveys enable row level security;

create policy surveys_select_own on public.monthly_surveys
  for select to authenticated using (
    member_id in (select id from public.members where user_id = auth.uid()));

revoke all on public.monthly_surveys from anon, authenticated;
grant select on public.monthly_surveys to authenticated;
revoke all on function public.submit_survey(text, jsonb) from public, anon;
grant execute on function public.submit_survey(text, jsonb) to authenticated;
