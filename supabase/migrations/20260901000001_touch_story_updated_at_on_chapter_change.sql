-- The "Updated" date shown on a story's preview page reads stories.updated_at,
-- which only changes via the existing set_stories_updated_at trigger -- fired
-- on direct UPDATEs to the stories row itself. Adding/editing/removing a
-- story_chapters row (the actual chapter content) never touches that trigger,
-- so a story whose content changes only through its chapters silently shows a
-- stale "Updated" date. This adds the missing propagation, and backfills the
-- rows that already went stale that way.

create or replace function public.touch_story_updated_at_from_chapter()
returns trigger as $$
begin
  update public.stories
  set updated_at = now()
  where id = coalesce(new.story_id, old.story_id);
  return coalesce(new, old);
end;
$$ language plpgsql;

create trigger story_chapters_touch_story_updated_at
  after insert or update or delete on public.story_chapters
  for each row execute function public.touch_story_updated_at_from_chapter();

-- One-time backfill: any story whose newest chapter is newer than the
-- story's own updated_at was already stale before this trigger existed.
update public.stories s
set updated_at = newest.max_chapter_created_at
from (
  select story_id, max(created_at) as max_chapter_created_at
  from public.story_chapters
  group by story_id
) as newest
where newest.story_id = s.id
  and newest.max_chapter_created_at > s.updated_at;
