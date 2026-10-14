-- Points a family member earns in a family game (a right answer, winning). Anyone in the family can award
-- them (the game is played on one phone for several people), but only small amounts, one call at a time.
create function public.award_points(p_member_id uuid, p_points int)
returns void
language plpgsql security definer set search_path = public
as $$
declare me public.members := public.my_member(); target public.members;
begin
  select * into target from public.members where id = p_member_id;
  if me.id is null or target.id is null or me.family_id <> target.family_id then
    raise exception 'not_allowed' using errcode = '42501';
  end if;
  if p_points not between 1 and 30 then raise exception 'bad_amount' using errcode = '22023'; end if;
  update public.members set points = points + p_points where id = p_member_id;
end $$;
revoke all on function public.award_points(uuid, int) from public, anon;
grant execute on function public.award_points(uuid, int) to authenticated;
