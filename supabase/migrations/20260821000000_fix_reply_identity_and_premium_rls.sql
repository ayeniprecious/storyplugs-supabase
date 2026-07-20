-- Two real bugs, found together:
--
-- 1. comments_insert_own's WITH CHECK only ever allowed the official account
--    to post a reply (parent_id is not null) -- a premium user's reply was
--    silently rejected by RLS despite the client UI (canReply in
--    comments-section.tsx) telling them they could reply. Premium replying
--    was never actually functional.
--
-- 2. The UI has no way to tell whether a given reply's author IS the official
--    account, so comments-section.tsx rendered the "Official Reply" badge on
--    every reply unconditionally -- misleading once premium users can reply
--    too. Fixing #1 without this makes it worse, not better.

alter table public.profiles add column is_official_account boolean not null default false;

update public.profiles set is_official_account = true
where id = (select id from auth.users where email = 'storyplugs@gmail.com');

drop policy "comments_insert_own" on public.comments;
create policy "comments_insert_own" on public.comments
  for insert with check (
    auth.uid() = user_id
    and exists (select 1 from public.stories s where s.id = story_id and s.status = 'published')
    and (
      parent_id is null
      or public.is_official_account()
      or exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_premium)
    )
  );

-- Appended at the end -- CREATE OR REPLACE VIEW can't reorder existing columns.
create or replace view public.public_commenter_profiles as
  select p.id, p.display_name, p.avatar_url, public.current_reading_streak(p.id) as current_streak,
    p.is_premium, p.is_official_account
  from public.profiles p
  where exists (
    select 1
    from public.comments c
    join public.stories s on s.id = c.story_id
    where c.user_id = p.id and s.status = 'published'
  );

grant select on public.public_commenter_profiles to authenticated;
