-- 20260718000000's comments_insert_own policy queried auth.users directly
-- inside its WITH CHECK clause. That subquery runs as the invoking
-- (authenticated) role, which has no SELECT grant on auth.users -- caller
-- got "permission denied for table users" trying to post any reply.
-- Fix: route the check through a security definer function, same pattern as
-- is_admin()/is_super_admin()/current_reading_streak().
create or replace function public.is_official_account()
returns boolean as $$
  select exists (
    select 1 from auth.users where id = auth.uid() and email = 'storyplugs@gmail.com'
  );
$$ language sql stable security definer set search_path = public;

drop policy "comments_insert_own" on public.comments;
create policy "comments_insert_own" on public.comments
  for insert with check (
    auth.uid() = user_id
    and exists (select 1 from public.stories s where s.id = story_id and s.status = 'published')
    and (parent_id is null or public.is_official_account())
  );
