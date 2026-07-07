-- profiles_select_own restricts every user to their own row, which is right
-- for the sensitive fields (gender, date_of_birth, interests, push_token,
-- notification prefs) but breaks comment authorship -- there's no way to
-- show another user's display name/avatar next to their comment.
--
-- This view exposes ONLY id/display_name/avatar_url, and ONLY for users who
-- have posted at least one comment on a published story -- not the whole
-- user directory. It intentionally omits security_invoker so it runs as the
-- view owner and bypasses profiles' restrictive RLS internally; the WHERE
-- clause (not RLS) is what limits exposure to actual public commenters, and
-- the column list is what limits it to non-sensitive fields.
create or replace view public.public_commenter_profiles as
  select p.id, p.display_name, p.avatar_url
  from public.profiles p
  where exists (
    select 1
    from public.comments c
    join public.stories s on s.id = c.story_id
    where c.user_id = p.id and s.status = 'published'
  );

grant select on public.public_commenter_profiles to authenticated;
