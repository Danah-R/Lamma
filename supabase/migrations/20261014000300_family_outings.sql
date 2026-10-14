-- Outings the family suggests (on top of the built-in places). Anyone adds one, everyone sees it.
create table public.family_outings (
  id          uuid primary key default gen_random_uuid(),
  family_id   uuid not null references public.families (id) on delete cascade,
  member_id   uuid not null references public.members (id) on delete cascade,
  name        text not null check (char_length(btrim(name)) between 1 and 80),
  created_at  timestamptz not null default now()
);
create index family_outings_family_idx on public.family_outings (family_id, created_at);

create function public.add_outing(p_name text)
returns uuid
language plpgsql security definer set search_path = public
as $$
declare me public.members := public.my_member(); new_id uuid;
begin
  if me.id is null then raise exception 'not_in_family' using errcode = '42501'; end if;
  insert into public.family_outings (family_id, member_id, name) values (me.family_id, me.id, btrim(p_name)) returning id into new_id;
  return new_id;
end $$;

alter table public.family_outings enable row level security;
create policy outings_select on public.family_outings for select to authenticated using (family_id = public.my_family_id());
revoke all on public.family_outings from anon, authenticated;
grant select on public.family_outings to authenticated;
revoke all on function public.add_outing(text) from public, anon;
grant execute on function public.add_outing(text) to authenticated;
