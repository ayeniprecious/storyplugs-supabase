-- Exposes each commenter's premium status so the app can show an
-- Instagram-style ring around their avatar in comments (see
-- 20260718000000_comment_replies_and_streaks.sql for the current_streak
-- addition this follows the same pattern as).
create or replace view public.public_commenter_profiles as
  select p.id, p.display_name, p.avatar_url, public.current_reading_streak(p.id) as current_streak, p.is_premium
  from public.profiles p
  where exists (
    select 1
    from public.comments c
    join public.stories s on s.id = c.story_id
    where c.user_id = p.id and s.status = 'published'
  );

grant select on public.public_commenter_profiles to authenticated;
