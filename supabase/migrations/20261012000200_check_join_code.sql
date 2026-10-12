-- Lets the app validate a join code as soon as it is typed (before the person has
-- finished onboarding). Counts failed tries exactly like join_family does.
create function public.check_join_code(p_code text)
returns jsonb
language plpgsql security definer set search_path = public
as $$
declare
  uid uuid := auth.uid();
  code text := 'LAMMA-' || regexp_replace(
                 upper(regexp_replace(coalesce(p_code, ''), '\s', '', 'g')), '^LAMMA-?', '');
  fam public.families;
begin
  if uid is null then raise exception 'not_signed_in' using errcode = '28000'; end if;

  if (select count(*) from public.join_attempts
      where user_id = uid and created_at > now() - interval '1 hour') >= 8 then
    return jsonb_build_object('error', 'too_many_attempts');
  end if;

  select * into fam from public.families where join_code = code;
  if not found then
    insert into public.join_attempts (user_id) values (uid);
    return jsonb_build_object('error', 'invalid_code');
  end if;
  return jsonb_build_object('family_name', fam.name);
end $$;

revoke all on function public.check_join_code(text) from public, anon;
grant execute on function public.check_join_code(text) to authenticated;
