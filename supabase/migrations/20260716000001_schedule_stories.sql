-- Scheduled publishing: admins can set stories.published_at to a future
-- timestamp when publishing. The story stays hidden from public/mobile
-- reads until that time passes, enforced here at the RLS level so every
-- existing "published" query across the app respects the schedule
-- automatically, with no client-side changes needed.
drop policy if exists "stories_select_published" on public.stories;
create policy "stories_select_published" on public.stories
  for select using (status = 'published' and published_at <= now());
