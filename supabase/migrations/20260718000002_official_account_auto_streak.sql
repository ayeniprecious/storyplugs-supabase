-- The official StoryPlugs account's streak shouldn't depend on it actually
-- opening stories -- it's the "king" account. Special-case it to count days
-- since the account was created instead of reading reading_activity, so the
-- streak (surfaced via public_commenter_profiles.current_streak, e.g. on
-- comment avatar badges) climbs automatically, forever.
create or replace function public.current_reading_streak(target_user_id uuid)
returns integer as $$
declare
  latest date;
  streak integer := 1;
  expected date;
  d date;
  joined_date date;
begin
  if exists (select 1 from auth.users where id = target_user_id and email = 'storyplugs@gmail.com') then
    select created_at::date into joined_date from public.profiles where id = target_user_id;
    return greatest(1, (current_date - coalesce(joined_date, current_date))::int + 1);
  end if;

  select max(activity_date) into latest from public.reading_activity where user_id = target_user_id;
  if latest is null or current_date - latest > 1 then
    return 0;
  end if;

  expected := latest - 1;
  for d in
    select activity_date from public.reading_activity
    where user_id = target_user_id and activity_date < latest
    order by activity_date desc
  loop
    if d = expected then
      streak := streak + 1;
      expected := expected - 1;
    else
      exit;
    end if;
  end loop;

  return streak;
end;
$$ language plpgsql stable security definer set search_path = public;
