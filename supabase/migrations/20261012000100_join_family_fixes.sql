-- join_family fixes:
--  * wrong codes now RETURN {"error": "..."} instead of raising. A raised error rolls
--    back the failed-attempt row, so the "8 failures per hour" limit never counted.
--  * the code is forgiving: any case, spaces, and with or without "LAMMA" / the dash.
create or replace function public.join_family(p_code text, p_profile jsonb)
returns jsonb
language plpgsql security definer set search_path = public
as $$
declare
  uid uuid := auth.uid();
  code text := 'LAMMA-' || regexp_replace(
                 upper(regexp_replace(coalesce(p_code, ''), '\s', '', 'g')), '^LAMMA-?', '');
  fam public.families;
  m public.members;
begin
  if uid is null then raise exception 'not_signed_in' using errcode = '28000'; end if;
  if exists (select 1 from public.members where user_id = uid) then
    raise exception 'already_in_family' using errcode = 'P0001';
  end if;

  if (select count(*) from public.join_attempts
      where user_id = uid and created_at > now() - interval '1 hour') >= 8 then
    return jsonb_build_object('error', 'too_many_attempts');
  end if;

  select * into fam from public.families where join_code = code;
  if not found then
    insert into public.join_attempts (user_id) values (uid);
    return jsonb_build_object('error', 'invalid_code');
  end if;

  m := public.insert_member(fam.id, p_profile, false);

  return jsonb_build_object('family_id', fam.id, 'family_name', fam.name,
                            'join_code', fam.join_code, 'member_id', m.id);
end $$;

revoke all on function public.join_family(text, jsonb) from public, anon;
grant execute on function public.join_family(text, jsonb) to authenticated;
