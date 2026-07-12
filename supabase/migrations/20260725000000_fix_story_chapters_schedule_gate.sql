-- story_chapters_select_published only ever checked status = 'published', never
-- picking up the published_at <= now() check that stories_select_published got in
-- 20260716000001_schedule_stories.sql for scheduled publishing. A scheduled-but-
-- not-yet-live story's chapters were therefore readable via direct API even though
-- the story row itself was correctly hidden. Close that gap.
drop policy if exists "story_chapters_select_published" on public.story_chapters;

create policy "story_chapters_select_published" on public.story_chapters
  for select using (
    exists (
      select 1 from public.stories s
      where s.id = story_chapters.story_id
        and s.status = 'published'
        and s.published_at <= now()
    )
  );
