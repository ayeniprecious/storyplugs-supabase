-- Comment replies, restricted to the official StoryPlugs account, plus each
-- commenter's current reading streak exposed publicly (for an avatar badge).

-- ========== COMMENTS: replies ==========
alter table public.comments add column parent_id uuid references public.comments(id) on delete cascade;
create index comments_parent_idx on public.comments (parent_id);

-- Replace the insert policy so replying (parent_id not null) is only allowed
-- for the storyplugs@gmail.com account -- not every admin, just that one
-- account -- while top-level comments still work the same for everyone.
drop policy "comments_insert_own" on public.comments;
create policy "comments_insert_own" on public.comments
  for insert with check (
    auth.uid() = user_id
    and exists (select 1 from public.stories s where s.id = story_id and s.status = 'published')
    and (
      parent_id is null
      or exists (select 1 from auth.users u where u.id = auth.uid() and u.email = 'storyplugs@gmail.com')
    )
  );

-- ========== READING STREAKS: expose current streak publicly ==========
-- Mirrors the client-side computeStreaks() logic in use-reading-streak.ts
-- (current streak only): 0 if the most recent activity is more than a day
-- old, otherwise count consecutive days backward from the latest entry.
-- security definer so it can read any user's reading_activity despite that
-- table's "select own only" RLS -- same pattern as is_admin()/is_super_admin().
create or replace function public.current_reading_streak(target_user_id uuid)
returns integer as $$
declare
  latest date;
  streak integer := 1;
  expected date;
  d date;
begin
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

-- public_commenter_profiles already exposes id/display_name/avatar_url for
-- commenters (see 20260717000000_public_commenter_profiles.sql); add each
-- commenter's current streak so the app can badge their avatar with it.
create or replace view public.public_commenter_profiles as
  select p.id, p.display_name, p.avatar_url, public.current_reading_streak(p.id) as current_streak
  from public.profiles p
  where exists (
    select 1
    from public.comments c
    join public.stories s on s.id = c.story_id
    where c.user_id = p.id and s.status = 'published'
  );

grant select on public.public_commenter_profiles to authenticated;
