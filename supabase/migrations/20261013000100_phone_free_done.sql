-- Any family member's phone can switch the phone-free time off once its window is over (the app decides
-- from the clock). Only the "phoneFree" flag changes; everything else in the parents' rules is untouched.
create function public.phone_free_done()
returns void
language plpgsql security definer set search_path = public
as $$
declare
  me public.members := public.my_member();
begin
  if me.id is null then raise exception 'not_in_family' using errcode = '42501'; end if;
  update public.family_rules
     set data = jsonb_set(data, '{phoneFree}', 'false'::jsonb), updated_at = now()
   where family_id = me.family_id;
end $$;
revoke all on function public.phone_free_done() from public, anon;
grant execute on function public.phone_free_done() to authenticated;
