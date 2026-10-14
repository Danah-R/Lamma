-- Topics the family wants to talk about: anyone adds one, everyone sees it, and it is marked once talked about.
create table public.family_topics (
  id            uuid primary key default gen_random_uuid(),
  family_id     uuid not null references public.families (id) on delete cascade,
  member_id     uuid not null references public.members (id) on delete cascade,
  text          text not null check (char_length(btrim(text)) between 1 and 200),
  discussed_at  timestamptz,
  created_at    timestamptz not null default now()
);
create index family_topics_family_idx on public.family_topics (family_id, created_at);

create function public.add_topic(p_text text)
returns uuid
language plpgsql security definer set search_path = public
as $$
declare me public.members := public.my_member(); new_id uuid;
begin
  if me.id is null then raise exception 'not_in_family' using errcode = '42501'; end if;
  insert into public.family_topics (family_id, member_id, text) values (me.family_id, me.id, btrim(p_text)) returning id into new_id;
  return new_id;
end $$;

create function public.topic_discussed(p_id uuid)
returns void
language plpgsql security definer set search_path = public
as $$
declare me public.members := public.my_member();
begin
  if me.id is null then raise exception 'not_in_family' using errcode = '42501'; end if;
  update public.family_topics set discussed_at = coalesce(discussed_at, now()) where id = p_id and family_id = me.family_id;
end $$;

alter table public.family_topics enable row level security;
create policy topics_select on public.family_topics for select to authenticated using (family_id = public.my_family_id());
revoke all on public.family_topics from anon, authenticated;
grant select on public.family_topics to authenticated;
revoke all on function public.add_topic(text) from public, anon;
revoke all on function public.topic_discussed(uuid) from public, anon;
grant execute on function public.add_topic(text) to authenticated;
grant execute on function public.topic_discussed(uuid) to authenticated;
